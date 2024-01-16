// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CentralGameBase.sol";
import "./GameBet.sol";
import "./GameVRF.sol";
import "./IRakeDistributor.sol";
import "./ITreasury.sol";

/// @title Flip!
/// @notice Upgraded Flip contract using a global treasury and multiple flips
contract Flip is CentralGameBase, GameBet, GameVRF {
    enum RoundChoice {
        HEADS, // 0
        TAILS // 1
    }

    struct RoundInfo {
        RoundChoice selected;
        RoundState state;
        uint256 sent;
    }

    event GameStarted(
        address indexed creator,
        uint256 indexed gameId,
        uint8 subgame,
        uint8 numRounds,
        RoundChoice[] choices,
        address referrer,
        uint256 betPerRound,
        uint256 rakePerRound,
        FulfillmentMethod method
    );
    event WinnerPicked(uint256 indexed gameId, RoundInfo[] results);

    /// Per-game user choices, by gameId.
    mapping(uint256 => RoundChoice[]) public choicesByGameId;
    uint256 l;

    /// Contract can be funded.
    receive() external payable {}

    constructor(address initialOwner) GameVRF() Ownable(initialOwner) {}

    function playGame(
        RoundChoice[] memory choices,
        string memory referralCode,
        FulfillmentMethod method
    ) external payable isEOA isNotPaused returns (uint256) {
        IRakeDistributor rakeDistributor = IRakeDistributor(
            rakeDistributorAddress
        );
        uint8 numRounds = uint8(choices.length);
        BetDetails memory details = validateBet(
            treasuryAddress.balance,
            500,
            numRounds
        );
        console.log(
            "Transferring from %s to %s tokens , treasury %s",
            msg.sender,
            msg.value,
            treasuryAddress
        );
        l = rakeDistributor.getTotalRake();
        console.log("rakeDistributor l", l);
        address referrer = rakeDistributor.getReferrerFromGamerAndCode(
            msg.sender,
            referralCode
        );
        currentGameId++;
        GameInfo memory fi;
        fi.creator = msg.sender;
        fi.referrer = referrer;
        fi.gameId = currentGameId;
        fi.state = GameState.CALCULATING;
        fi.numRounds = numRounds;
        fi.betPerRound = details.betPerRound;
        fi.rakePerRound = details.rakePerRound;
        fi.subgame = 1;
        gameById[fi.gameId] = fi;
        choicesByGameId[fi.gameId] = choices;
        console.log("details.bet %s", details.bet);
        {
            (bool success, ) = payable(treasuryAddress).call{
                value: details.bet
            }("");
            require(success, "Failed to send to treasury");
        }
        //debugg this
        console.log("rakeDistributorAddress", rakeDistributorAddress);
        rakeDistributor.distributeReferredRake{value: details.rake}(
            fi.gameId,
            msg.sender,
            referrer
        );
        gameById[fi.gameId] = fi;
        _requestGameFulfillment(fi.gameId, method);

        // Synthetically adjust the flip counter forward by the number of flips.
        // This leaves gaps in the mapping, but it's useful for the offline storage.
        currentGameId += choices.length - 1;

        emit GameStarted(
            msg.sender,
            fi.gameId,
            fi.subgame,
            numRounds,
            choices,
            fi.referrer,
            fi.betPerRound,
            fi.rakePerRound,
            method
        );
        return fi.gameId;
    }

    /// Receives the random number from VRF and calculates win/loss/tie.
    /// Transfers the appropriate amount of funds from treasury to the user on wins.
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        uint256 gameId = gameIdByRequestId[requestId];
        GameInfo storage fi = gameById[gameId];
        ITreasury treasury = ITreasury(treasuryAddress);

        RoundChoice[] memory savedChoices = choicesByGameId[gameId];
        uint256 choicesLength = savedChoices.length;
        RoundInfo[] memory results = new RoundInfo[](choicesLength);

        uint256 winnings = 0;

        for (uint i = 0; i < choicesLength; i++) {
            uint256 flipRandom = uint256(
                keccak256(abi.encode(randomWords[0], i))
            );
            results[i].selected = flipRandom % 2 == 0
                ? RoundChoice.HEADS
                : RoundChoice.TAILS;
            results[i].state = RoundState.LOST;
            if (savedChoices[i] == results[i].selected) {
                results[i].state = RoundState.WON;
                winnings += fi.betPerRound;
                results[i].sent = fi.betPerRound * 2;
            }
        }

        if (winnings > 0) {
            treasury.sendPayout(fi.creator, winnings * 2);
        }

        fi.state = GameState.CLOSED;
        emit WinnerPicked(gameId, results);
        delete gameById[gameId];
    }

    /// Triggers VRF process for a given game in case of emergency.
    function forceRequestWinner(
        uint256 flipId,
        FulfillmentMethod method
    ) external onlyOwner {
        GameInfo storage fi = gameById[flipId];
        require(fi.state != GameState.CLOSED, "already closed");
        _requestGameFulfillment(fi.gameId, method);
    }
}

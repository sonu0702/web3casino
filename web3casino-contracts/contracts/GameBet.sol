// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "hardhat/console.sol";

abstract contract GameBet is Ownable2Step {
    // minimum allowed bet
    uint256 public minBet = 0.1 ether;

    // Maximum single bet amount is treasury divided by this.
    uint256 public maxBetDivisor = 20;

    // Maximum number of rounds that can
    // be played in a single game.
    //
    //
    uint256 public maxConsecutiveRounds = 10;

    // Bet amounts per round must be a multiple
    // of this
    uint256 public betMultiplePerRound = 0.01 ether;

    struct BetDetails {
        uint256 bet;
        uint256 rake;
        uint256 betPerRound;
        uint256 rakePerRound;
        uint256 payoutPerRound;
    }

    function validateBet(
        uint256 treasuryBalance,
        uint256 totalRake,
        uint numRounds
    ) internal returns (BetDetails memory) {
        // 1.05
        // (2 * 10000) / (500 + 10000)
        //TODO: TBU
        // TODO: this is retarded, pass the bet in instead?
        //what ever is in msg.value
        console.log("msg value %s",msg.value);
        uint256 bet = ((msg.value * 10000) / (totalRake + 10000));
        //msg tatalRake % of msg.value
        uint256 rake = msg.value - bet;
        console.log("bet %s and rake %s minBet %s", bet, rake,minBet);
        require(bet >= minBet, "Gameble more");

        // TODO: This should probably apply to the potentialWin instead of the bet amount
        // Currently this assumes 2x win values?
        // TODO: TBU
        console.log("bet <= (treasuryBalance / maxBetDivisor) %s maxBetDivisor %s",
        treasuryBalance,
        maxBetDivisor);
        require(bet <= (treasuryBalance / maxBetDivisor), "Gamble less");

        require(numRounds > 0, "Gamble atleast once");
        require(numRounds <= maxConsecutiveRounds, "Gamble fewer times");

        uint256 betPerRound = bet / numRounds;
        require(
            bet % numRounds == 0,
            "Gamble an amount divisible by your bets"
        );
        console.log(
            "check:Gamble an amount divisible by your bets",
            bet % numRounds
        );
        require(
            betPerRound % betMultiplePerRound == 0,
            "Gamble the right amount per bet"
        );
        console.log(
            "check:Gamble the right amount per bet %s,betPerRound %s, betMultiplePerRound %s",
            betPerRound % betMultiplePerRound,
            betPerRound,
            betMultiplePerRound
        );
        uint256 rakePerRound = rake / numRounds;
        require(rake % numRounds == 0, "Internal error; wrong rake amount");
        console.log("check:wrong rake amount", rake % numRounds);
        return
            BetDetails({
                bet: bet,
                rake: rake,
                betPerRound: betPerRound,
                rakePerRound: rakePerRound,
                payoutPerRound: 0
            });
    }

    function validateBetWithPayout(
        uint256 treasuryBalance,
        uint256 totalRake,
        uint256 numRounds,
        uint256 betNumerator,
        uint256 betDenominator
    ) internal returns (BetDetails memory) {
        uint256 bet = ((msg.value * 10000) / (totalRake + 10000));
        uint256 maxPayoutValue = (bet * betNumerator) / betDenominator;
        return
            validateBetWithMaxPayoutValue(
                treasuryBalance,
                totalRake,
                numRounds,
                maxPayoutValue
            );
    }

    function validateBetWithMaxPayoutValue(
        uint256 treasuryBalance,
        uint256 totalRake,
        uint256 numRounds,
        uint256 maxPayoutValue
    ) internal returns (BetDetails memory) {
        require(numRounds > 0, "Gamble at least one round, pleb");
        uint256 bet = ((msg.value * 10000) / (totalRake + 10000));
        uint256 rake = msg.value - bet;

        require(bet >= minBet, "Gamble more, pleb");

        require(numRounds > 0, "Gamble at least once, pleb");
        require(numRounds <= maxConsecutiveRounds, "Gamble fewer times, king");

        uint256 betPerRound = bet / numRounds;
        require(
            bet % numRounds == 0,
            "Gamble an amount divisible by your bets, pleb"
        );
        require(
            betPerRound % betMultiplePerRound == 0,
            "Gamble the right amount per bet, pleb"
        );

        uint256 rakePerRound = rake / numRounds;
        require(rake % numRounds == 0, "Internal error; wrong rake amount");

        uint256 maxPayoutPerRound = maxPayoutValue / numRounds;
        require(
            betPerRound < maxPayoutPerRound,
            "Place a gamble that won't guarantee you lose, pleb"
        );
        require(
            maxPayoutPerRound - betPerRound <=
                (treasuryBalance / maxBetDivisor),
            "Gamble less, king"
        );

        return
            BetDetails({
                bet: bet,
                rake: rake,
                betPerRound: betPerRound,
                rakePerRound: rakePerRound,
                payoutPerRound: maxPayoutPerRound
            });
    }

    function setMinBet(uint256 minBet_) external onlyOwner {
        minBet = minBet_;
    }

    function setMaxBetDivisor(uint256 maxBetDivisor_) external onlyOwner {
        maxBetDivisor = maxBetDivisor_;
    }

    function setMaxConsecutiveRounds(
        uint256 maxConsecutiveRounds_
    ) external onlyOwner {
        maxConsecutiveRounds = maxConsecutiveRounds_;
    }

    function setBetMultiple(uint256 betMultiplePerRound_) external onlyOwner {
        betMultiplePerRound = betMultiplePerRound_;
    }
}

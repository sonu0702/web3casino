// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";

abstract contract CentralGameBase is Ownable2Step {
    //Status of individual betting round in a game.
    enum RoundState {
        UNKNOWN,
        LOST,
        TIE,
        WON
    }

    //Status of the game, consisting of set of rounds.
    enum GameState {
        // waiting for RNG
        CALCULATING,
        // Game is finalized and no actions can be taken
        CLOSED,
        // For PvP games, waiting for 1 or more other player
        WAITING_FOR_PLAYER,
        // For PvP games, the game creator cancelled play.
        CANCELLED
    }

    // Every game played has game info created for it.
    // The details for the individual game are stored separately per game.
    struct GameInfo {
        uint256 gameId;
        uint256 betPerRound;
        uint256 rakePerRound;
        address creator;
        address referrer;
        uint8 subgame;
        uint8 numRounds;
        GameState state;
    }

    // Incrementing counter for the current gameId.
    uint256 public currentGameId;

    // Standardized GameInfo structs mapped by gameId.
    mapping(uint256 => GameInfo) public gameById;

    // Global switch to disallow play.
    bool public paused;

    // Address of the rake distributor.
    address public rakeDistributorAddress;

    // Address of the referral tracker.
    address public referralTrackerAddress;

    // Address of the treasury.
    address public treasuryAddress;

    // Prevent contracts from playing, with this modifier
    modifier isEOA() {
        require(tx.origin == msg.sender, "No contract allowed");
        _;
    }

    // Prevent play when the game is paused.
    modifier isNotPaused() {
        require(!paused, "Game is paused");
        _;
    }

    // Withdraws Fund to contract owner in case of emergency
    function rescueFund(uint256 amount) external onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success);
    }

    // Ferch details about an individual game
    function getGameInfo(uint256 gameId) public view returns (GameInfo memory) {
        return gameById[gameId];
    }

    // Fetch details about many games simultaneously
    function getManyGameInfo(
        uint256[] memory gameIds
    ) public view returns (GameInfo[] memory) {
        uint gameIdLength = gameIds.length;
        GameInfo[] memory ret = new GameInfo[](gameIdLength);
        for (uint i; i < gameIdLength; ++i) {
            ret[i] = gameById[gameIds[i]];
        }
        return ret;
    }

    
    function setPaused(bool _paused) public onlyOwner {
        paused = _paused;
    }

    function setReckDistributor(address rakeAddress) external onlyOwner {
        rakeDistributorAddress = rakeAddress;
    }

    function setTreasuryAddress(address _treasuryAddress) external onlyOwner {
        treasuryAddress = _treasuryAddress;
    }

    function setReferralTrackerAddress(address _referralTrackerAddress) external onlyOwner{
        referralTrackerAddress=_referralTrackerAddress;
    }

    function setCurrentGameId(uint256 _gameId) external onlyOwner {
        currentGameId = _gameId;
    }
}

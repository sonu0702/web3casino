// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITreasury {
    function sendPayout(address gamer, uint256 amount) external;

    function setGame(address game, bool isValid) external;
}

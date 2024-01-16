// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IRakeDistributor {
    function getTotalRake() external view returns (uint256);

    function distributeRake() external payable;

    function distributeReferredRake(
        uint256 gameId,
        address player,
        address referrer
    ) external payable;

    function getReferrerFromGamerAndCode(
        address gamer,
        string memory referralCode
    ) external view returns (address);

    function setOperator(address operator, bool isValid) external;
}

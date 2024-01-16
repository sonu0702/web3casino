//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IReferralTracker {
   function setAndGetReferrerForGamer(address gamer, address referrer) external returns (address);

    function referrerByWallet(address gamer) external view returns (address);

    function getReferrerFromGamerAndCode(address gamer, string memory code) external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * Modified version of Chainlinks VRFConsumerBase to use multiple coordinators
 * ***************************************************************************** 
 * 
 * @dev Calling contracts must inherit from VRFConsumerBase
 * 
 * @dev USAGE
 * 
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
**/

import "@openzeppelin/contracts/access/Ownable2Step.sol";

abstract contract MultipleVRFConsumerBase is Ownable2Step {
  error OnlyCoordinatorCanFulfill(address have);
  mapping(address => bool) private vrfCoordinators;

  function setVRFCoordinator(address coordinator, bool active) public onlyOwner {
	vrfCoordinators[coordinator] = active;
  }

  /**
   * @notice fulfillRandomWords handles the VRF response. Your contract must
   * @notice implement it.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomWords is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (vrfCoordinators[msg.sender] != true) {
      revert OnlyCoordinatorCanFulfill(msg.sender);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}
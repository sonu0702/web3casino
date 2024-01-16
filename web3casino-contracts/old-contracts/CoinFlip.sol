// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

contract CoinFlip is VRFConsumerBaseV2, ConfirmedOwner {
    event CoinFlipRequest(uint256 requestId);
    event CoinFlipResponse(uint256 requestId, bool didWin);

    struct CoinFlipStatus {
        uint256 fees;
        uint256 randomWord;
        address player;
        bool didWin;
        bool fulfilled;
        CoinFlipSelection choice;
        bool requestIdExists;
    }
    enum CoinFlipSelection {
        HEADS,
        TAILS
    }
    mapping(uint256=>CoinFlipStatus) public statuses;
    uint64 s_subscriptionId;
    VRFCoordinatorV2Interface COORDINATOR;
    uint128 constant entryFee = 0.00001 ether;
    uint32 constant callbackGasLimit = 100000;
    uint32 constant numWords = 1;
    uint16 constant requestConfirmations = 3;
    bytes32 keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    constructor(uint64 subscriptionId)
    VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625)  
    ConfirmedOwner(msg.sender)
    payable {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
        );
        s_subscriptionId = subscriptionId;
    }

    function flip(CoinFlipSelection choice) 
    external
    payable
    returns(uint256 requestId){
        require(msg.value == entryFee,"Entry fees not sent");
         // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        statuses[requestId] = CoinFlipStatus({
            fees:0,
            randomWord:0,
            player:msg.sender,
            didWin:false,
            fulfilled:false,
            choice:choice,
            requestIdExists:true
        });
        emit CoinFlipRequest(requestId)  ;
        return requestId;
    }
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(statuses[_requestId].requestIdExists,'request not found');
        statuses[_requestId].fulfilled = true;
        statuses[_requestId].randomWord = _randomWords[0];
        CoinFlipSelection result = CoinFlipSelection.HEADS;
        if(_randomWords[0]%2 ==0){
            result = CoinFlipSelection.TAILS;
        }
        if(statuses[_requestId].choice == result){
            statuses[_requestId].didWin = true;
            payable(statuses[_requestId].player).transfer(entryFee*2);
        }
        emit CoinFlipResponse(_requestId,statuses[_requestId].didWin);
    }

    function getStatus(uint256 requestId) 
    public
    view
    returns (CoinFlipStatus memory){
        return statuses[requestId];
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
//this import is differnt than one which is deployed by fredy
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "./MultipleVRFConsumerBase.sol";

abstract contract GameVRF is MultipleVRFConsumerBase {
    enum FulfillmentMethod {
        CHAINLINK, // 0
        FERDY, // 1
        ONCHAIN // 2
    }

    struct CoordinatorInfo {
        bytes32 gasLane;
        address coordAddress;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
    }

    mapping(FulfillmentMethod => CoordinatorInfo) private coordinatorInfoByMethod;
    /// Minimum on AVAX is 2; might need changing for other games.
    uint16 private _requestConfirmations = 2;
    uint32 private constant NUM_WORDS = 1;

    /// Game ids mapped by VRF request ID
    /// Keeps track of which request was for which game, so they can be fulfilled
    mapping(uint256 => uint256) public gameIdByRequestId;

    /// Emitted when a VRF request has been sent for a game.
    event RequestedGameWinner(uint256 indexed requestId, address indexed vrfCoordinator, uint256 indexed gameId);

    constructor() {}

    function setVRFCoordinatorInfoByMethod(FulfillmentMethod method, bytes32 gasLane, address coordAddress, uint64 subscriptionId, uint32 callbackGasLimit) external onlyOwner {
        coordinatorInfoByMethod[method] = CoordinatorInfo(gasLane, coordAddress, subscriptionId, callbackGasLimit);
        setVRFCoordinator(coordAddress, true);
    }

    /// Requests VRF for a game and tracks the mapping from request to game.
    function _requestGameFulfillment(uint256 gameId, FulfillmentMethod method) internal {
        address coordinatorAddress = coordinatorInfoByMethod[method].coordAddress;
        require(coordinatorAddress != address(0), "Invalid VRF address");
        VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(coordinatorAddress);

        uint256 requestId = vrfCoordinator.requestRandomWords(
            coordinatorInfoByMethod[method].gasLane,
            coordinatorInfoByMethod[method].subscriptionId,
            _requestConfirmations,
            coordinatorInfoByMethod[method].callbackGasLimit,
            NUM_WORDS
        );
        gameIdByRequestId[requestId] = gameId;
    }

    function getRequestConfirmations() public view returns (uint16) {
        return _requestConfirmations;
    }

    function setRequestConfirmations(uint16 requestConfirmations) public onlyOwner {
        _requestConfirmations = requestConfirmations;
    }

    function getNumWords() public pure returns (uint256) {
        return NUM_WORDS;
    }
}
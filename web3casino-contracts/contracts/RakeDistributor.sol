//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IReferralTracker.sol";

contract RakeDistributor is Ownable {
    uint32 public totalRake = 500; // 5% of base amount

    uint32 public teamRake = 6000; // 60% of rake amount
    uint32 public nftRake = 2000; // 20% of rake amount
    uint32 public referralRake = 2000; // 20% of rake amount
    address public nftAddress = 0x41Fc1fF1623Fa6713F83f06d1EBB2725f4eb57DA;
    address public teamAddress = 0xe00A3f7B30B66Eedeb20E410E72b0F06435F8F09;
    address public referralTrackerAddress;
    mapping(address => bool) public operators;

    enum RakeType {
        TEAM,
        FERDY,
        REFERRAL
    }

    event RakePayment(
        address indexed game,
        RakeType rakeType,
        uint256 gameId,
        address player,
        address destination,
        uint256 amount
    );

    modifier onlyOperator() {
        require(operators[msg.sender] == true, "Must be operator!");
        _;
    }

    constructor(address initialOnwer) Ownable(initialOnwer) {
        operators[msg.sender] = true;
    }

    function setOperator(address operator, bool isValid) external onlyOwner {
        operators[operator] = isValid;
    }

    function setTotalRake(uint32 _totalRake) external onlyOwner {
        totalRake = _totalRake;
    }

    function setNFTRake(uint32 _nftRake) external onlyOwner {
        nftRake = _nftRake;
    }

    function setTeamRake(uint32 _teamRake) external onlyOwner {
        teamRake = _teamRake;
    }

    function setReferralRake(uint32 _referralRake) external onlyOwner {
        referralRake = _referralRake;
    }

    function setTeamAddress(address _teamAddress) external onlyOwner {
        teamAddress = _teamAddress;
    }

    function setNFTAddress(address _nftAddress) external onlyOwner {
        nftAddress = _nftAddress;
    }

    function setReferralTrackerAddress(
        address _referralTrackerAddress
    ) external onlyOwner {
        referralTrackerAddress = _referralTrackerAddress;
    }

    function getTotalRake() external view returns (uint256) {
        return totalRake;
    }

    function getReferrerFromGamerAndCode(
        address gamer,
        string memory referralCode
    ) public view returns (address) {
        IReferralTracker referralTracker = IReferralTracker(
            referralTrackerAddress
        );
        return referralTracker.getReferrerFromGamerAndCode(gamer, referralCode);
    }

    function distributeRake() external payable {
        require(
            teamRake + referralRake + nftRake == 10_000,
            "Rake configured incorrectly"
        );
        uint256 teamRakeAmount = (msg.value * (teamRake + referralRake)) /
            10000;
        uint256 nftRakeAmount = (msg.value * nftRake) / 10000;
        (bool success, ) = payable(teamAddress).call{value: teamRakeAmount}("");
        require(success, "could not pay team");
        (success, ) = payable(nftAddress).call{value: nftRakeAmount}("");
        require(success, "could not pay ferds");
    }

    function distributeReferredRake(
        uint256 gameId,
        address player,
        address referrer
    ) external payable onlyOperator {
        IReferralTracker referralTracker = IReferralTracker(
            referralTrackerAddress
        );
        referrer = referralTracker.setAndGetReferrerForGamer(player, referrer);
        require(
            teamRake + referralRake + nftRake == 10_000,
            "Rake configured incorrectly"
        );

        uint256 nftRakeAmount = (msg.value * nftRake) / 10000;
        uint256 referralRakeAmount = (msg.value * referralRake) / 10000;
        uint256 teamRakeAmount = (msg.value * teamRake) / 10000;

        if (nftRakeAmount > 0) {
            (bool success, ) = payable(nftAddress).call{value: nftRakeAmount}(
                ""
            );
            require(success, "could not pay ferds");
            emit RakePayment(
                msg.sender,
                RakeType.FERDY,
                gameId,
                player,
                nftAddress,
                nftRakeAmount
            );
        }

        if (referrer != address(0) && referralRakeAmount > 0) {
            (bool success, ) = payable(referrer).call{
                value: referralRakeAmount
            }("");
            require(success, "could not pay referrer");
            emit RakePayment(
                msg.sender,
                RakeType.REFERRAL,
                gameId,
                player,
                referrer,
                referralRakeAmount
            );
        } else {
            teamRakeAmount = teamRakeAmount + referralRakeAmount;
        }

        if (teamRakeAmount > 0) {
            (bool success, ) = payable(teamAddress).call{value: teamRakeAmount}(
                ""
            );
            require(success, "could not pay team");
            emit RakePayment(
                msg.sender,
                RakeType.TEAM,
                gameId,
                player,
                teamAddress,
                teamRakeAmount
            );
        }
    }
}

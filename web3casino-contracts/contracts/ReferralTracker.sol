// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

/// A contract to track referrals per wallet
contract ReferralTracker is Ownable {
    mapping(address => address) public referrerByWallet;
    mapping(bytes32 => address) public referrerByCode;
    mapping(address => string) public codeByReferrer;
    mapping(address => bool) public operators;
    address constant NO_REFERRER = address(1);

    modifier onlyOperator() {
        console.log(
            "msg.sender",msg.sender,"operators[msg.sender]",operators[msg.sender]
        );
        require(operators[msg.sender] == true, "Must be operator!");
        _;
    }

    constructor(address initialAddress) Ownable(initialAddress) {
        // Make sure nobody hijacks sentinel (gross) value code
        referrerByCode[getHashFromCode("")] = NO_REFERRER;
    }

    function setOperator(address operator, bool isValid) external onlyOwner {
        operators[operator] = isValid;
    }

    function setReferralCode(string memory code) public {
        bytes32 codeHash = getHashFromCode(code);
        require(
            referrerByCode[codeHash] == address(0),
            "Referral code must be unique."
        );
        require(
            getHashFromCode(codeByReferrer[msg.sender]) == getHashFromCode(""),
            "Referral code already set"
        );

        referrerByCode[codeHash] = msg.sender;
        codeByReferrer[msg.sender] = code;
    }

    function getReferrerFromCode(
        string memory code
    ) public view returns (address) {
        address referrer = referrerByCode[getHashFromCode(code)];
        if (referrer == NO_REFERRER) {
            return address(0);
        }
        return referrer;
    }

    //TODO: side effect-y?
    function setAndGetReferrerForGamer(
        address gamer,
        address referrer
    ) public onlyOperator returns (address) {
        address setReferrer = referrerByWallet[gamer];

        // Already used our site
        if (setReferrer == NO_REFERRER) {
            return address(0);
        }

        // base referral case, have an actual referral set that's not noReferrer
        if (setReferrer != address(0)) {
            return setReferrer;
        }

        // first time setting (setRefferer was address(0))

        // self-referrers or non-referred users are noReferrer for life
        if (gamer == referrer || referrer == address(0)) {
            referrerByWallet[gamer] = NO_REFERRER;
            return address(0);
        }

        referrerByWallet[gamer] = referrer;
        return referrer;
    }

    function getReferrerFromGamerAndCode(
        address gamer,
        string memory code
    ) public view returns (address) {
        address referrer = referrerByWallet[gamer];
        console.log(
            "getReferrerFromGamerAndCode gamer %s code %s referer %s",
            gamer,
            code,
            referrer
        );
        // Non-referrals are for this contract only
        if (referrer == NO_REFERRER) {
            return address(0);
        }
        console.log("referrer == NO_REFERRER done");
        // Normal referral return
        if (referrer != address(0)) {
            return referrer;
        }
        console.log("referrer != address(0) done");
        referrer = getReferrerFromCode(code);

        // Self referral attempts are denied
        if (referrer == gamer) {
            return address(0);
        }
        console.log("referrer === gamer , return referrer %s",referrer );
        // return the new referrer (will be set later)
        return referrer;
    }

    function getHashFromCode(string memory code) public pure returns (bytes32) {
        return bytes32(bytes(code));
    }

    function bytes32ToString(
        bytes32 _bytes32
    ) internal pure returns (string memory) {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function adminSetReferralCode(
        string memory code,
        address referrer
    ) public onlyOwner {
        bytes32 codeHash = getHashFromCode(code);
        referrerByCode[codeHash] = referrer;
        codeByReferrer[msg.sender] = code;
    }

    function adminSetReferralWallet(
        address gamer,
        address referrer
    ) public onlyOwner {
        referrerByWallet[gamer] = referrer;
    }
}

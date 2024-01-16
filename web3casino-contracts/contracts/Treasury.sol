// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Treasury {
    constructor() payable {}

    function sendPayout(address gamer, uint256 amount) external {
        payable(gamer).transfer(amount);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

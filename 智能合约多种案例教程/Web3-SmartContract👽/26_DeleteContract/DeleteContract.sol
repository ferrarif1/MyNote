// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// selfdestruct

contract DeleteContract {

    uint public value = 10;

    constructor() payable {}

    receive() external payable {}

    function deleteContract() external {
        //selfdestruct ETH msg.sender
        selfdestruct(payable(msg.sender));
    }

    function getBalance() external view returns(uint balance){
        balance = address(this).balance;
    }
}

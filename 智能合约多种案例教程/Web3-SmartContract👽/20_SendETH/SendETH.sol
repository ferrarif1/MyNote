// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// ETH
// transfer: 2300 gas, revert
// send: 2300 gas, return bool
// call: all gas, return (bool, data)

error SendFailed(); // senD ETH error
error CallFailed(); // call ETH error

contract SendETH {
    // payable eth
    constructor() payable{}
    // receive，eth
    receive() external payable{}

    // transfer() ETH
    function transferETH(address payable _to, uint256 amount) external payable{
        _to.transfer(amount);
    }

    // send() ETH
    function sendETH(address payable _to, uint256 amount) external payable{
        // send revert error
        bool success = _to.send(amount);
        if(!success){
            revert SendFailed();
        }
    }

    // call() ETH
    function callETH(address payable _to, uint256 amount) external payable{
        //call，revert error
        (bool success,) = _to.call{value: amount}("");
        if(!success){
            revert CallFailed();
        }
    }
}

contract ReceiveETH {
    
    event Log(uint amount, uint gas);


    receive() external payable{
        emit Log(msg.value, gasleft());
    }
    

    function getBalance() view public returns(uint) {
        return address(this).balance;
    }
}

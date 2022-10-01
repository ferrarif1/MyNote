// SPDX-License-Identifier: MIT
// By 0xAA
pragma solidity ^0.8.4;

import "./IERC20.sol"; //import IERC20

contract ERC20 is IERC20 {

    mapping(address => uint256) public override balanceOf;

    mapping(address => mapping(address => uint256)) public override allowance;

    uint256 public override totalSupply;   

    string public name;   
    string public symbol;  
    
    uint8 public decimals = 18; 

    constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    }

    //  transfer
    function transfer(address recipient, uint amount) external override returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // `approve` 
    function approve(address spender, uint amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // transferFrom`
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external override returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // mint
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // burn
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

}

// ERC20
contract Faucet {

    uint256 public amountAllowed = 100; // 
    address public tokenContract;   // token
    mapping(address => bool) public requestedAddress;   

    // SendToken
    event SendToken(address indexed Receiver, uint256 indexed Amount); 

    // ERC20
    constructor(address _tokenContract) {
        tokenContract = _tokenContract; // set token contract
    }

    // request token
    function requestTokens() external {
        require(requestedAddress[msg.sender] == false, "Can't Request Multiple Times!"); 
        IERC20 token = IERC20(tokenContract); // 
        require(token.balanceOf(address(this)) >= amountAllowed, "Faucet Empty!"); 

        token.transfer(msg.sender, amountAllowed); 
        requestedAddress[msg.sender] = true; 
        
        emit SendToken(msg.sender, amountAllowed); // SendToken
    }
}
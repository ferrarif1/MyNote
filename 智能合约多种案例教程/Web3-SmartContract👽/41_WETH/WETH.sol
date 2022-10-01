// SPDX-License-Identifier: MIT
// original contract on ETH: https://rinkeby.etherscan.io/token/0xc778417e063141139Fce010982780140aa0cd5ab?a=0xe16c1623c1aa7d919cd2241d8b36d9e79c1be2a2#code
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20{
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    
    constructor() ERC20("WETH", "WETH"){
    }

    // WETH ETH，deposit()
    fallback() external payable {
        deposit();
    }
    // ，WETH ETH ，deposit()
    receive() external payable {
        deposit();
    }


    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    
    function withdraw(uint amount) public {
        require(balanceOf(msg.sender) >= amount);
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
}
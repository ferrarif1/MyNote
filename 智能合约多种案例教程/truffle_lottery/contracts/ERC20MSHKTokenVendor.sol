// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20MSHKToken.sol";

// Learn more about the ERC20 implementation 
// on OpenZeppelin docs: https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20MSHKTokenVendor is Ownable {

  // Our Token Contract
  ERC20MSHKToken mshkToken;

  // token price for ETH
  uint256 public tokensPerEth = 100;

  // 定义买卖事件
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  constructor(address tokenAddress) {
    //创建 ERC20合约实例
    mshkToken = ERC20MSHKToken(tokenAddress);
  }

  /**
  * 允许用户使用BNB购买 Token
  */
  function buyTokens() public payable returns (uint256 tokenAmount) {
    // 发送的数量必须大于0
    require(msg.value > 0, "Send ETH to buy some tokens");

    // 计算后的代币买入数量
    uint256 amountToBuy = msg.value * tokensPerEth;

    // 检查合约中的代币是否足够
    // address(this) 合约实例的地址
    // msg.sender 合约调用的地址
    // 以上两个概念要区分开,参考： https://docs.soliditylang.org/en/develop/units-and-global-variables.html
    uint256 vendorBalance = mshkToken.balanceOf(address(this));
    require(vendorBalance >= amountToBuy, "Vendor contract has not enough tokens in its balance");

    // 向合约的调用者发送代币 
    (bool sent) = mshkToken.transfer(msg.sender, amountToBuy);
    require(sent, "Failed to transfer token to user");

    // 注册事件
    emit BuyTokens(msg.sender, msg.value, amountToBuy);

    return amountToBuy;
  }

  /**
  * 允许用户卖出 Token 换回 BNB
  */
  function sellTokens(uint256 tokenAmountToSell) public {
    // 检查数量是否大于0
    require(tokenAmountToSell > 0, "Specify an amount of token greater than zero");

    // 检测调用合约者的代币是否足够
    uint256 userBalance = mshkToken.balanceOf(msg.sender);
    require(userBalance >= tokenAmountToSell, "Your balance is lower than the amount of tokens you want to sell");

    // 检查该合约中的ETH余额是否足够
    uint256 amountOfETHToTransfer = tokenAmountToSell / tokensPerEth;
    uint256 ownerETHBalance = address(this).balance;
    require(ownerETHBalance >= amountOfETHToTransfer, "Vendor has not enough funds to accept the sell request");

    // 从合约调用者向合约发送代币
    (bool sent) = mshkToken.transferFrom(msg.sender, address(this), tokenAmountToSell);
    require(sent, "Failed to transfer tokens from user to vendor");

    // 向合约调用者发送指定的 BNB
    (sent,) = msg.sender.call{value: amountOfETHToTransfer}("");
    require(sent, "Failed to send ETH to the user");

    // 注册事件
    emit SellTokens(msg.sender, tokenAmountToSell, amountOfETHToTransfer);

  }

  /**
  * 允许我们转出所有的BNB，测试时使用
  */
  function withdraw() public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "Owner has not balance to withdraw");

    // 将合约中的全部 BNB 转出到调用者，且只能是 owner
    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send user balance back to the owner");
  }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 了解有关 ERC20 实施的更多信息
// 在 OpenZeppelin 文档上：https://docs.openzeppelin.com/contracts/4.x/erc20
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20MSHKToken is ERC20 {
    constructor() ERC20("MSHK ERC20 Token", "MSHK") {
        // 向合约创建者发送 1000 个有18位小数的代币
        _mint(msg.sender, 100000 * 10 ** 18); // 总量 1000个
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./libs/PermLib.sol";
// 铸造Token
contract ZeroToken is ERC20 {
    // 合约创建的管理者
    using PermLib for *;
    PermLib.PermConf private permConf;

    constructor() ERC20("ZERO ERC20 Token", "ZERO") {
        // 合约地址本身发送 1000 个有18位小数的代币
        permConf.admin = msg.sender;
        _mint(address(this), 10000 * 10000 * 10**18); // 总量 1000个
    }

    modifier onlyWhite() {
        require(permConf.admin == msg.sender || permConf.whiteAddress == msg.sender,"You are not allow");
        _;
    }

    modifier onlyOwner() {
        require(permConf.admin == msg.sender, "You are not the owner");
        _;
    }

    function setAllowAddress(address addr) public onlyOwner {
         permConf.whiteAddress = addr;
    }

    function allowAdminSendToken(address to,uint256  amount) public onlyWhite {
        require(balanceOf(address(this)) > amount,"contract address Insufficient amount");
        _transfer(address(this), to, amount);
    }
    
    function getThisBalance() public view returns (uint256) {
        return balanceOf(address(this));
    }

    function getBalance(address addr) public view returns (uint256) {
        return balanceOf(addr);
    }
    
}

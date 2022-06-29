// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Mytoken is ERC20, Ownable {
    event Airdropperlog(address indexed _to, uint256 _value);

    constructor() ERC20("mytoken", "MTK") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function Airdropper(address[] calldata  _to, uint256[] calldata _account)  public onlyOwner returns (bool) {
        require(_to.length > 0 && _to.length == _account.length);
        for(uint i = 0; i < _to.length; i++){
             transfer(_to[i], _account[i]);
             emit Airdropperlog(_to[i], _account[i]);
        }
        return true;
    }
}
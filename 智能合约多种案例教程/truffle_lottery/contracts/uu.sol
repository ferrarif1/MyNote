pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract uu is Ownable,ERC20 {
 
   constructor() public ERC20("U ERC20", "UE") {
        _mint(address(this),1000000 * 10 ** 18);
    }

    function stake(uint _amount) public {
       transferFrom(address(this), msg.sender, 100);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Owner {
   address public owner; // owner

   // 
   constructor() {
      owner = msg.sender; // ，owner
   }

   // modifier
   modifier onlyOwner {
      require(msg.sender == owner); // owner
      _; // revert
   }

   // onlyOwner
   function changeOwner(address _newOwner) external onlyOwner{
      owner = _newOwner; 
   }
}

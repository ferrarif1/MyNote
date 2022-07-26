//SPDX-License-identifier: MIT 
pragma solidity ^0.8.0;

contract Data {
  uint internal _data;

  function getData() public view returns(uint) {
    return _data;
  }
}
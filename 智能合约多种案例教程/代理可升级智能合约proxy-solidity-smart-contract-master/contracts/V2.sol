//SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

import "./Data.sol";

contract V2 is Data{

  event V2LogicCallEvent(uint data);
  function logicCall(uint a, uint b) external {
    _data = a + b;
    emit V2LogicCallEvent(_data);
  }
}
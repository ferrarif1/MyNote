//SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import "./Data.sol";

contract V1 is Data {

  event V1LogicCallEvent(uint data);

  function logicCall(uint a, uint b) external {
    _data = a - b;
    emit V1LogicCallEvent(_data);
  }
}
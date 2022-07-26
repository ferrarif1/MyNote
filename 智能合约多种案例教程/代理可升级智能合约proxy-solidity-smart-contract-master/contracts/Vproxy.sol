//SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

import "./Data.sol";

contract Vproxy is Data {
  address private _owner;
  address private _contractAddress;

  event UpdatenContractAddress(address indexed newContractAddress);

  constructor(address contractAddress){
    _contractAddress = contractAddress;
    _owner = msg.sender;
    emit UpdatenContractAddress(contractAddress);
  }

  modifier onlyOwner{
    require (_owner == msg.sender,"Vproxy: Caller was not owner");
    _;
  }

  fallback() external payable {
    bool successCall = false;
    bytes memory retData;
    (successCall, retData) = _contractAddress.delegatecall(msg.data);
    require(successCall, "Proxy: Internal call was failed");
  }

  //@TODO: imporve this by using multisignature algorithm
  function updateContractAddress(address _newAddress) external onlyOwner{
    require(_newAddress != address(0), "Invalid address, failed to update addresss");

    _contractAddress = _newAddress;
  }

  function getContractAddress() public view returns(address) {
    return _contractAddress;
  }

  function getOwner() public view returns(address) {
    return _owner;  
  }

  function changeOwner(address _newOnwerAddress) public onlyOwner {
    _owner = _newOnwerAddress;
  }
}
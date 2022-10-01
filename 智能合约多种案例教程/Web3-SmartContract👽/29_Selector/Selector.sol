// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Selector{
    // event msg.data
    event Log(bytes data);

    // to: 0x2c44b726ADF1963cA47Af88B284C06f30380fC78
    function mint(address /*to*/) external{
        emit Log(msg.data);
    } 

    // selector
    // "mint(address)"： 0x6a627842
    function mintSelector() external pure returns(bytes4 mSelector){
        return bytes4(keccak256("mint(address)"));
    }

    // selector
    function callWithSignature() external returns(bool, bytes memory){
        // abi.encodeWithSelector`mint``selector`
        (bool success, bytes memory data) = address(this).call(abi.encodeWithSelector(0x6a627842, "0x2c44b726ADF1963cA47Af88B284C06f30380fC78"));
        return(success, data);
    }
}

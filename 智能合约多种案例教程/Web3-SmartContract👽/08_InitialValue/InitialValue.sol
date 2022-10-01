// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract InitialValue {
    // Value Types
    bool public _bool; // false
    string public _string; // ""
    int public _int; // 0
    uint public _uint; // 0
    address public _address; // 0x0000000000000000000000000000000000000000

    enum ActionSet { Buy, Hold, Sell}
    ActionSet public _enum; 

    function fi() internal{} // internal
    function fe() external{} // external

    // Reference Types
    uint[8] public _staticArray; 
    uint[] public _dynamicArray; // `[]`
    mapping(uint => address) public _mapping; //mapping
    

    struct Student{
        uint256 id;
        uint256 score; 
    }
    Student public student;

    // delete
    bool public _bool2 = true; 
    function d() external {
        delete _bool2; // delete bool2，false
    }
}

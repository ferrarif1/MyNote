// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract DataStorage {
    // The data location of x is storage.
    // This is the only place where the
    // data location can be omitted.
    uint[] x = [1,2,3];

    function fStorage() public{
        
        uint[] storage xStorage = x;
        xStorage[0] = 100;
    }

    function fMemory() public view{
        
        uint[] memory xMemory = x;
        xMemory[0] = 100;
        xMemory[1] = 200;
        uint[] memory xMemory2 = x;
        xMemory2[0] = 300;
    }

    function fCalldata(uint[] calldata _x) public pure returns(uint[] calldata){
        
        return(_x);
    }
}

contract Variables {
    uint public x = 1;
    uint public y;
    string public z;

    function foo() external{
        
        x = 5;
        y = 2;
        z = "0xAA";
    }

    function bar() external pure returns(uint){
        uint xx = 1;
        uint yy = 3;
        uint zz = xx + yy;
        return(zz);
    }

    function global() external view returns(address, uint, bytes memory){
        address sender = msg.sender;
        uint blockNum = block.number;
        bytes memory data = msg.data;
        return(sender, blockNum, data);
    }
}




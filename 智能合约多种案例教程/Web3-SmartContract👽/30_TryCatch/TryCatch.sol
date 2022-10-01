// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract OnlyEven{
    constructor(uint a){
        require(a != 0, "invalid number");
        assert(a != 1);
    }

    function onlyEven(uint256 b) external pure returns(bool success){
        // REVERT
        require(b % 2 == 0, "Ups! Reverting");
        success = true;
    }
}

contract TryCatch {
    // event
    event SuccessEvent();
    // event
    event CatchEvent(string message);
    event CatchByte(bytes data);

    // OnlyEven
    OnlyEven even;

    constructor() {
        even = new OnlyEven(2);
    }
    
    // 在xternal call try-catch
    // execute(0 SuccessEvent`
    // execute(1)CatchEvent`
    function execute(uint amount) external returns (bool success) {
        try even.onlyEven(amount) returns(bool _success){
            // call
            emit SuccessEvent();
            return _success;
        } catch Error(string memory reason){
            // call
            emit CatchEvent(reason);
        }
    }

    // try-catch （external call）
    // executeNew(0)`CatchEvent`
    // executeNew(1)CatchByte`
    // executeNew(2)SuccessEvent`
    function executeNew(uint a) external returns (bool success) {
        try new OnlyEven(a) returns(OnlyEven _even){
            // call
            emit SuccessEvent();
            success = _even.onlyEven(a);
        } catch Error(string memory reason) {
            // catch revert()  require()
            emit CatchEvent(reason);
        } catch (bytes memory reason) {
            // catch assert()
            emit CatchByte(reason);
        }
    }
}

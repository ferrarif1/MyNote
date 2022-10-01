// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import
import './Yeye.sol';

import {Yeye} from './Yeye.sol';

import '@openzeppelin/contracts/utils/Address.sol';

import '@openzeppelin/contracts/access/Ownable.sol';

contract Import {
    // Address
    using Address for address;
    // yeye
    Yeye yeye = new Yeye();

    //yeye
    function test() external{
        yeye.hip();
    }
}

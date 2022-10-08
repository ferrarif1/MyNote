//SPDX-License-Identifier: MIT
//Author: @beauwilliams

pragma solidity 0.8.7;

import "./ExampleVerifier.sol";

// struct Proof {
//     uint256[2] a;
//     uint256[2][2] b;
//     uint256[2] c;
// }

contract VerifierImplementation is Verifier {
    constructor() {}

    //An example function that will call Verifier.verifyProof(A, B, C, input)
    function VerifyExample(
        uint256[2] memory a,
        uint256[2] memory b_0,
        uint256[2] memory b_1,
        uint256[2] memory c,
        //This is the user input
        uint256[1] memory input
    ) public view returns (bool) {
        bool res = verifyProof(a, [b_0, b_1], c, input);
        return res;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

 
 
contract RandomNumberConsumer is VRFConsumerBase {
    
    bytes32 internal keyHash; 
    uint256 internal fee; 
    
    uint256 public randomResult; 
    
    /**
     * VRFConsumerBase 
     
     * Rinkeby
     * Chainlink VRF Coordinator : 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK : 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */
    constructor() 
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
        )
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (VRF，Rinkeby)
    }
        
    
    function getRandomNumber() public returns (bytes32 requestId) {
        // LINK
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }
}

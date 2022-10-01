// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
*/
import "../34_ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomNumber is ERC721, VRFConsumerBase{
    // NFT
    uint256 public totalSupply = 100; 
    uint256[100] public ids; 
    uint256 public mintCount; 
    // chainlink VRF
    bytes32 internal keyHash;
    uint256 internal fee;

    // mint
    mapping(bytes32 => address) public requestToSender;
    /**
     * chainlink VRF，VRFConsumerBase 
     * 
     * : Rinkeby
     * Chainlink VRF Coordinator : 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK : 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */
    constructor() 
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
        )
        ERC721("ICON Random", "ICON")
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (，Rinkeby
    }
    
    /** 
    * uint256，mint tokenId
    */
    function pickRandomUniqueId(uint256 random) private returns (uint256 tokenId) {
        
        uint256 len = totalSupply - mintCount++;  
        require(len > 0, "mint close"); 
        uint256 randomIndex = random % len; 

        //，tokenId，value len-1，tokenId value
        tokenId = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex; 
        ids[randomIndex] = ids[len - 1] == 0 ? len - 1 : ids[len - 1]; 
        ids[len - 1] = 0; /gas
    }

    /** 
    * keccak256(abi.encodePacked()
    * uint256
    */
    function getRandomOnchain() public view returns(uint256){
        
        bytes32 randomBytes = keccak256(abi.encodePacked(blockhash(block.number-1), msg.sender, block.timestamp));
        return uint256(randomBytes);
    }

    // NFT
    function mintRandomOnchain() public {
        uint256 _tokenId = pickRandomUniqueId(getRandomOnchain()); // 利用链上随机数生成tokenId
        _mint(msg.sender, _tokenId);
    }

    /** 
     * VRF，mintNFT
     * requestRandomness()，VRF fulfillRandomness()
     */
    function mintRandomVRF() public returns (bytes32 requestId) {
        // LINK
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        // requestRandomness
        requestId = requestRandomness(keyHash, fee);
        requestToSender[requestId] = msg.sender;
        return requestId;
    }

    /**
     * VRF，VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        address sender = requestToSender[requestId]; // requestToSendermint
        uint256 _tokenId = pickRandomUniqueId(randomness); // VRFtokenId
        _mint(sender, _tokenId);
    }
}

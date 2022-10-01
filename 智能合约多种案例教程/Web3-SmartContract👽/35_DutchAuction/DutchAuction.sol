// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../34_ERC721/ERC721.sol";

contract DutchAuction is Ownable, ERC721 {
    uint256 public constant COLLECTOIN_SIZE = 10000; 
    uint256 public constant AUCTION_START_PRICE = 1 ether; 
    uint256 public constant AUCTION_END_PRICE = 0.1 ether; 
    uint256 public constant AUCTION_TIME = 10 minutes; 
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes; 
    uint256 public constant AUCTION_DROP_PER_STEP =
        (AUCTION_START_PRICE - AUCTION_END_PRICE) /
        (AUCTION_TIME / AUCTION_DROP_INTERVAL); //
    
    uint256 public auctionStartTime; 
    string private _baseTokenURI;   
    uint256[] private _allTokens; 

    constructor() ERC721("WTF Dutch Auctoin", "WTF Dutch Auctoin") {
        auctionStartTime = block.timestamp;
    }

    /**
     * ERC721Enumerable中totalSupply
     */
    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }

    /**
     * Private  allTokens一token
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }

    // mint
    function auctionMint(uint256 quantity) external payable{
        uint256 _saleStartTime = uint256(auctionStartTime); 
        require(
        _saleStartTime != 0 && block.timestamp >= _saleStartTime,
        "sale has not started yet"
        ); // 
        require(
        totalSupply() + quantity <= COLLECTOIN_SIZE,
        "not enough remaining reserved for auction to support desired mint amount"
        ); // 

        uint256 totalCost = getAuctionPrice(auctionStartTime) * quantity; // mint
        require(msg.value >= totalCost, "Need to send more ETH."); // ETH
        
        // Mint NFT
        for(uint i = 0; i < quantity; i++) {
            uint mintIndex = totalSupply();
            _mint(msg.sender, mintIndex);
            _addTokenToAllTokensEnumeration(mintIndex);
        }
        // ETH
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }

    
    function getAuctionPrice(uint256 _auctionStartTime)
        public
        view
        returns (uint256)
    {
        if (block.timestamp < _auctionStartTime) {
        return AUCTION_START_PRICE;
        }else if (block.timestamp - _auctionStartTime >= AUCTION_TIME) {
        return AUCTION_END_PRICE;
        } else {
        uint256 steps = (block.timestamp - _auctionStartTime) /
            AUCTION_DROP_INTERVAL;
        return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }

    // auctionStartTime setter，onlyOwner
    function setAuctionStartTime(uint32 timestamp) external onlyOwner {
        auctionStartTime = timestamp;
    }

    // BaseURI
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
    // BaseURI setter, onlyOwner
    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }
    // onlyOwner
    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}

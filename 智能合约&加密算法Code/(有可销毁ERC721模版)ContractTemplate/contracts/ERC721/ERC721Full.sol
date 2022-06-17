pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Holder.sol";
import "@openzeppelin/contracts/drafts/Counters.sol";
//全功能ERC721代币
contract ERC721FullContract is ERC721Full, ERC721Holder {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(
        string memory name, //代币名称
        string memory symbol,//代币缩写
        string memory baseURI//代币基本地址
    ) ERC721Full(name, symbol) public {
        _setBaseURI(baseURI);
    }

    function awardItem(address player, string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}
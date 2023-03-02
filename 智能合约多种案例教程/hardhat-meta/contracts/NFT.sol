// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.13;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC2771Context, ERC721 {
    using SafeMath for uint256;

    uint256 private _currentTokenId = 0;

    constructor(
        string memory name,
        string memory symbol,
        address trustedForwarder
    ) ERC721(name, symbol) ERC2771Context(trustedForwarder) {}

    function safeMint() public virtual {
        safeMint("");
    }

    function safeMint(bytes memory _data) internal virtual {
        uint256 tokenId = _getNextTokenId();
        _incrementTokenId();
        _safeMint(_msgSender(), tokenId, _data);
    }
    
    function getCurrTokenId() public virtual view returns (uint256) {
        return _currentTokenId;
    }

    /**
     * @dev calculates the next token ID based on value of _currentTokenId
     * @return uint256 for the next token ID
     */
    function _getNextTokenId() internal virtual view returns (uint256) {
        return _currentTokenId.add(1);
    }

    /**
     * @dev increments the value of _currentTokenId
     */
    function _incrementTokenId() internal virtual {
        _currentTokenId++;
    }

    function _msgSender() internal view virtual override(Context, ERC2771Context) returns (address) {
        return ERC2771Context._msgSender();
    }

    function _msgData() internal view virtual override(Context, ERC2771Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
    }
}

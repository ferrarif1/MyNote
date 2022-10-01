// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../34_ERC721/ERC721.sol";


/**
 * Merkle
 * Keccak-256, hashLeaves sortPairs
 * 4
    [
    "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", 
    "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
    "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
    "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"
 * merkle proof
    [
    "0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb",
    "0x4726e4102af77216b09ccd94f40daa10531c87c4d60bba7f3b3faf5ff9f19b3c"
    ]
 * Merkle root: 0xeeefd63003e0e702cb41cd0043015a6e26ddb38073cc6ffeb0ba3e808ba8c097
 */


/**
 * @dev Merkle
 *
 * proof JavaScript
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 *  hash keccak256， pair sorting .
 * javascript`https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/test/utils/cryptography/MerkleProof.test.js`.
 */
library MerkleProof {
    /**
     * @dev proof`leaf``root``root``true`，
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns Merkle`leaf`proof``root`. `root``root`，`proof`
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    // Sorted Pair Hash
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}

contract MerkleTree is ERC721 {
    bytes32 immutable public root; // Merkle
    mapping(address => bool) public mintedAddress;   // mint

    // NFT、Merkle
    constructor(string memory name, string memory symbol, bytes32 merkleroot)
    ERC721(name, symbol)
    {
        root = merkleroot;
    }

    // Merkle mint
    function mint(address account, uint256 tokenId, bytes32[] calldata proof)
    external
    {
        require(_verify(_leaf(account), proof), "Invalid merkle proof"); // Merkle
        require(!mintedAddress[account], "Already minted!"); // mint
        
        mintedAddress[account] = true; //mint address
        _mint(account, tokenId); // mint
    }

    // Merkle
    function _leaf(address account)
    internal pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(account));
    }

    // Merkle，MerkleProofverify()
    function _verify(bytes32 leaf, bytes32[] memory proof)
    internal view returns (bool)
    {
        return MerkleProof.verify(proof, root, leaf);
    }
}

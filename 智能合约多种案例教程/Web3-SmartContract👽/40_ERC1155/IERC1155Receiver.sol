// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../34_ERC721/IERC165.sol";

/**
 * @dev ERC1155，ERC1155
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev ERC1155`safeTransferFrom` 
     *  0xf23a6e61 `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev`safeBatchTransferFrom` 
     * 0xbc197c81 `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

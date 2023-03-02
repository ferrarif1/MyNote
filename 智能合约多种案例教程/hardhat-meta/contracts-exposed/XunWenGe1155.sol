// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../contracts/XunWenGe1155.sol";

contract $XunWenGe is XunWenGe {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor(address trustedForwarder) XunWenGe(trustedForwarder) {}

    function $_msgSender() external view returns (address ret0) {
        (ret0) = super._msgSender();
    }

    function $_msgData() external view returns (bytes memory ret0) {
        (ret0) = super._msgData();
    }

    function $_checkRole(bytes32 role) external view {
        super._checkRole(role);
    }

    function $_checkRole(bytes32 role,address account) external view {
        super._checkRole(role,account);
    }

    function $_setupRole(bytes32 role,address account) external {
        super._setupRole(role,account);
    }

    function $_setRoleAdmin(bytes32 role,bytes32 adminRole) external {
        super._setRoleAdmin(role,adminRole);
    }

    function $_grantRole(bytes32 role,address account) external {
        super._grantRole(role,account);
    }

    function $_revokeRole(bytes32 role,address account) external {
        super._revokeRole(role,account);
    }

    function $_safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes calldata data) external {
        super._safeTransferFrom(from,to,id,amount,data);
    }

    function $_safeBatchTransferFrom(address from,address to,uint256[] calldata ids,uint256[] calldata amounts,bytes calldata data) external {
        super._safeBatchTransferFrom(from,to,ids,amounts,data);
    }

    function $_setURI(string calldata newuri) external {
        super._setURI(newuri);
    }

    function $_mint(address to,uint256 id,uint256 amount,bytes calldata data) external {
        super._mint(to,id,amount,data);
    }

    function $_mintBatch(address to,uint256[] calldata ids,uint256[] calldata amounts,bytes calldata data) external {
        super._mintBatch(to,ids,amounts,data);
    }

    function $_burn(address from,uint256 id,uint256 amount) external {
        super._burn(from,id,amount);
    }

    function $_burnBatch(address from,uint256[] calldata ids,uint256[] calldata amounts) external {
        super._burnBatch(from,ids,amounts);
    }

    function $_setApprovalForAll(address owner,address operator,bool approved) external {
        super._setApprovalForAll(owner,operator,approved);
    }

    function $_beforeTokenTransfer(address operator,address from,address to,uint256[] calldata ids,uint256[] calldata amounts,bytes calldata data) external {
        super._beforeTokenTransfer(operator,from,to,ids,amounts,data);
    }

    function $_afterTokenTransfer(address operator,address from,address to,uint256[] calldata ids,uint256[] calldata amounts,bytes calldata data) external {
        super._afterTokenTransfer(operator,from,to,ids,amounts,data);
    }

    receive() external payable {}
}

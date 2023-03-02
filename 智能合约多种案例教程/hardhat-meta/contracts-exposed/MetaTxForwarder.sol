// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../contracts/MetaTxForwarder.sol";

contract $MetaTxForwarder is MetaTxForwarder {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    function $_domainSeparatorV4() external view returns (bytes32 ret0) {
        (ret0) = super._domainSeparatorV4();
    }

    function $_hashTypedDataV4(bytes32 structHash) external view returns (bytes32 ret0) {
        (ret0) = super._hashTypedDataV4(structHash);
    }

    receive() external payable {}
}

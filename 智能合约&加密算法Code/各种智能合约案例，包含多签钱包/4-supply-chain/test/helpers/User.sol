// SPDX-License-Identifier: ISC
pragma solidity 0.8.4;

import "../../contracts/SupplyChain.sol";

contract User {

    /// @dev Necessary to fund the contract and receive Ether sent back by the SupplyChain contract.
    receive() external payable {}

    function addsItem(
        SupplyChain supplyChain,
        string calldata name,
        uint256 price
    ) external returns (uint256) {
        return supplyChain.addItem(name, price);
    }

    function buysItem(SupplyChain supplyChain, uint256 sku) external payable {
        supplyChain.buyItem{value: msg.value}(sku);
    }

    function triesToBuyItem(SupplyChain supplyChain, uint256 sku)
        external
        payable
        returns (bool bought)
    {
        (bought, ) = address(supplyChain).call{value: msg.value}(
            abi.encodeWithSignature("buyItem(uint256)", sku)
        );
    }

    function triesToShipItem(SupplyChain supplyChain, uint256 sku)
        external
        returns (bool shipped)
    {
        (shipped, ) = address(supplyChain).call(
            abi.encodeWithSignature("shipItem(uint256)", sku)
        );
    }

    function triesToReceiveItem(SupplyChain supplyChain, uint256 sku)
        external
        returns (bool received)
    {
        (received, ) = address(supplyChain).call(
            abi.encodeWithSignature("receiveItem(uint256)", sku)
        );
    }
}

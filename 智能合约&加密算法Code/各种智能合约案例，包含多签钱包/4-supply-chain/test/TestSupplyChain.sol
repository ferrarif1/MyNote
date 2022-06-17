// SPDX-License-Identifier: ISC
pragma solidity 0.8.4;

import "truffle/Assert.sol";
import "../contracts/SupplyChain.sol";
import "./helpers/User.sol";

contract TestSupplyChain {

    /// @dev Initial balance of test contract.
    uint256 public initialBalance = 2 ether;

    /// @dev Create two users that will be used to call the functions of the contract to be tested.
    User private aUser = new User();
    User private anotherUser = new User();

    function beforeAll() external {
        (bool funded, ) = address(aUser).call{value: 0.1 ether}("");
        require(funded, "Funding of aUser failed");

        (funded, ) = address(anotherUser).call{value: 0.1 ether}("");
        require(funded, "Funding of anotherUser failed");
    }

    /// @dev Instance of the contract to be tested, will be deployed before each test.
    SupplyChain private supplyChain;

    function beforeEach() external {
        supplyChain = new SupplyChain();
    }

    /* Buy Item */

    function testBuyItemSuccessfull() external {
        uint256 sku = aUser.addsItem(supplyChain, "my car", 0.001 ether);
        anotherUser.buysItem{value: 0.001 ether}(supplyChain, sku);

        (, , , SupplyChain.State itemState, , ) = supplyChain.items(sku);
        Assert.isTrue(
            itemState == SupplyChain.State.Sold,
            "Item should have been sold"
        );
    }

    function testBuyItemWithoutSufficientAmount() external {
        uint256 sku = aUser.addsItem(supplyChain, "my car", 0.001 ether);

        Assert.isFalse(
            anotherUser.triesToBuyItem{value: 0.0009 ether}(supplyChain, sku),
            "Should not be able to buy item without the sufficient sent amount"
        );
    }

    function testBuyItemThatIsNotForSale() external {
        uint256 sku = aUser.addsItem(supplyChain, "my car", 0.001 ether);
        anotherUser.buysItem{value: 0.001 ether}(supplyChain, sku);

        Assert.isFalse(
            anotherUser.triesToBuyItem(supplyChain, sku),
            "Should not be able to buy an item that is not for sale"
        );
    }

    /* Ship Item */

    function testShipItemCallNotMadeBySeller() external {
        uint256 sku = aUser.addsItem(supplyChain, "my car", 0.001 ether);
        anotherUser.buysItem{value: 0.001 ether}(supplyChain, sku);

        Assert.isFalse(
            anotherUser.triesToShipItem(supplyChain, sku),
            "Only the seller should be able to ship his item"
        );
    }

    function testShipItemThatIsNotSold() external {
        uint256 sku = aUser.addsItem(supplyChain, "my car", 0.001 ether);

        Assert.isFalse(
            anotherUser.triesToShipItem(supplyChain, sku),
            "Should not be able to ship an item that was not bought"
        );
    }

    /* Receive Item */

    function testReceiveItemCallNotMadeByBuyer() external {
        uint256 sku = aUser.addsItem(supplyChain, "my car", 0.001 ether);

        Assert.isFalse(
            aUser.triesToReceiveItem(supplyChain, sku),
            "Should not be able to receive an item that was not shipped"
        );
    }

    function testReceiveItemThatIsNotShipped() external {
        uint256 sku = aUser.addsItem(supplyChain, "my car", 0.001 ether);

        Assert.isFalse(
            anotherUser.triesToReceiveItem(supplyChain, sku),
            "Should not be able to receive an item that was not shipped"
        );
    }
}

// SPDX-License-Identifier: ISC
pragma solidity 0.8.4;

/// @notice This contract provides four different functions that let users to put up items for sale, let users buy such
/// items, let sellers notify the buyer that an item has been shipped and let buyers notify the seller that the item has
/// been received.
contract SupplyChain {
    /*
     * State variables
     */

    /// @notice Items mapped by their SKU.
    mapping(uint256 => Item) public items;

    /// @notice Number of items added.
    uint256 public itemCount = 0;

    /*
     * Enums and structures
     */

    /// @notice State of an item.
    enum State {ForSale, Sold, Shipped, Received}

    /// @notice An item.
    /// @param sku The SKU (Stock Keeping Unit) of the item.
    struct Item {
        uint256 sku;
        string name;
        uint256 price;
        State state;
        address payable seller;
        address payable buyer;
    }

    /*
     * Events
     */

    /// @notice An item has been put up for sale.
    event ForSale(uint256 sku);

    /// @notice An item has been sold.
    event Sold(uint256 sku);

    /// @notice An item has been shipped.
    event Shipped(uint256 sku);

    /// @notice An item has been received.
    event Received(uint256 sku);

    /*
     * Function modifiers
     */

    /// @notice The caller must be the seller of the item.
    modifier isSellerOf(uint256 sku) {
        require(msg.sender == items[sku].seller, "Caller must be the seller");
        _;
    }

    /// @notice The caller must be the buyer of the item.
    modifier isBuyerOf(uint256 sku) {
        require(msg.sender == items[sku].buyer, "Caller must be the buyer");
        _;
    }

    /// @notice The value of the transaction must be greater or equal to the price of the item.
    modifier paidEnoughFor(uint256 sku) {
        require(msg.value >= items[sku].price, "Insufficient payed amount");
        _;
    }

    /// @notice If the buyer has sent more Ether than the price of the item, the difference is refunded.
    modifier performRefundIfNeeded(uint256 sku) {
        _;

        uint256 refundAmount = msg.value - items[sku].price;
        if (refundAmount > 0) {
            (bool sent, ) = items[sku].buyer.call{value: refundAmount}("");
            require(sent, "Refund failed");
        }
    }

    /// @notice The item must be for sale.
    /// @dev Checking for item.state == State.ForSale is not sufficient because it will return true for an uninitialised
    ///      item (because the value of State.ForSale is 0).
    modifier isForSale(uint256 sku) {
        require(
            items[sku].state == State.ForSale &&
                items[sku].seller != address(0),
            "Item must be for sale"
        );
        _;
    }

    /// @notice The item must have been sold.
    modifier isSold(uint256 sku) {
        require(items[sku].state == State.Sold, "Item must have been sold");
        _;
    }

    /// @notice The item must have been shipped.
    modifier isShipped(uint256 sku) {
        require(
            items[sku].state == State.Shipped,
            "Item must have been shipped"
        );
        _;
    }

    /*
     * Functions
     */

    /// @notice Allows a user to put up an item for sale.
    function addItem(string calldata name, uint256 price)
        external
        returns (uint256)
    {
        items[itemCount] = Item({
            name: name,
            sku: itemCount,
            price: price,
            state: State.ForSale,
            seller: payable(msg.sender),
            buyer: payable(0)
        });

        emit ForSale(itemCount);
        return itemCount++;
    }

    /// @notice Allows a user to buy an existing for-sale item.
    function buyItem(uint256 sku)
        external
        payable
        isForSale(sku)
        paidEnoughFor(sku)
        performRefundIfNeeded(sku)
    {
        items[sku].state = State.Sold;
        items[sku].buyer = payable(msg.sender);

        (bool sent, ) = items[sku].seller.call{value: items[sku].price}("");
        require(sent, "Transfer failed");

        emit Sold(sku);
    }

    /// @notice Allows a seller to ship the given sold item.
    function shipItem(uint256 sku) external isSellerOf(sku) isSold(sku) {
        items[sku].state = State.Shipped;
        emit Shipped(sku);
    }

    /// @notice Allows a buyer to indicate he has received the item he had bought.
    function receiveItem(uint256 sku) external isBuyerOf(sku) isShipped(sku) {
        items[sku].state = State.Received;
        emit Received(sku);
    }

    /// @dev For testing purposes.
    function fetchItem(uint256 _sku)
        external
        view
        returns (
            uint256 sku,
            string memory name,
            uint256 price,
            uint256 state,
            address seller,
            address buyer
        )
    {
        return (
            items[_sku].sku,
            items[_sku].name,
            items[_sku].price,
            uint256(items[_sku].state),
            items[_sku].seller,
            items[_sku].buyer
        );
    }
}

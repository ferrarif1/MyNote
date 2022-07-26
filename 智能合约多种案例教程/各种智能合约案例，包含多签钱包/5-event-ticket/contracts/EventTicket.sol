// SPDX-License-Identifier: ISC
pragma solidity 0.8.6;

/// @notice This contract allows the owner to create events for which a given number of tickets can be sold at a given
/// price. It is possible for the owner to end the sale of tickets for an event and to receive the proceeds to the sale.
/// It is also possible for a buyer to get his tickets refunded.
contract EventTicket {

    /*
     * State variables
     */

    /// @notice Owner of the contract.
    address public owner;

    /// @notice Details of an event.
    struct Event {
        string description;
        string website;
        uint256 ticketPrice;
        uint256 totalTicketCount;
        uint256 ticketSoldCount;
        mapping(address => uint256) buyers;
        bool isOpen;
    }

    /// @notice All opened and closed events.
    mapping(uint256 => Event) private events;

    /// @notice Total number of events added.
    uint256 public eventCount = 0;

    /*
     * Events
     */

    /// @notice An event was added by the contract owner.
    event EventAdded(
        string description,
        string website,
        uint256 ticketPrice,
        uint256 totalTicketCount,
        uint256 eventId
    );

    /// @notice An event was ended by the contract owner.
    event EventEnded(uint256 eventId, uint256 proceeds);

    /// @notice Tickets were bought for an event.
    event TicketsBought(
        address indexed buyer,
        uint256 eventId,
        uint256 quantity
    );

    /// @notice Tickets were refunded to a buyer for an event.
    event TicketsRefunded(
        address indexed buyer,
        uint256 eventId,
        uint256 quantity
    );

    /*
     * Function modifiers
     */

    /// @notice Only the owner of the contract can add and end events.
    error SenderMustBeOwner();
    modifier isOwner() {
        if (msg.sender != owner) {
            revert SenderMustBeOwner();
        }
        _;
    }

    /// @notice Tickets can only be bought or refunded if the event is open.
    error EventNotOpen();
    modifier isEventOpen(uint256 eventId) {
        if (!events[eventId].isOpen) {
            revert EventNotOpen();
        }
        _;
    }

    /// @notice Not enough funds were sent to buy tickets of the event.
    error NotEnoughFundsSent();
    modifier enoughFundsSent(uint256 eventId, uint256 ticketQuantity) {
        if (msg.value < ticketQuantity * events[eventId].ticketPrice) {
            revert NotEnoughFundsSent();
        }
        _;
    }

    /// @notice The quantity of tickets to be bought exceeds the remaining quantity for sale.
    error NotEnoughTicketsRemaining();
    modifier enoughTicketsRemaining(uint256 eventId, uint256 ticketQuantity) {
        if (
            events[eventId].totalTicketCount - events[eventId].ticketSoldCount <
            ticketQuantity
        ) {
            revert NotEnoughTicketsRemaining();
        }
        _;
    }

    /// @notice The quantity of tickets to be refunded exceeds the quantity that was bought.
    error TicketsWereNotBought();
    modifier ticketsWereBought(uint256 eventId, uint256 ticketQuantity) {
        if (events[eventId].buyers[msg.sender] < ticketQuantity) {
            revert TicketsWereNotBought();
        }
        _;
    }

    /*
     * Functions
     */

    /// @notice Sets the contract owner.
    constructor() {
        owner = msg.sender;
    }

    /// @notice Lets the owner add a new event. The event will be automatically opened.
    function addEvent(
        string memory description, // TODO or storage ?
        string memory website,
        uint256 ticketPrice,
        uint256 totalTicketCount
    ) external isOwner() returns (uint256) {
        events[eventCount].description = description;
        events[eventCount].website = website;
        events[eventCount].ticketPrice = ticketPrice;
        events[eventCount].totalTicketCount = totalTicketCount;
        events[eventCount].isOpen = true;

        emit EventAdded(
            description,
            website,
            ticketPrice,
            totalTicketCount,
            eventCount
        );

        return eventCount++;
    }

    /// @notice Returns the details of the given event.
    function readEvent(uint256 eventId)
        external
        view
        returns (
            string memory description,
            string memory website,
            uint256 ticketPrice,
            uint256 totalTicketCount,
            uint256 ticketSoldCount,
            bool isOpen
        )
    {
        return (
            events[eventId].description,
            events[eventId].website,
            events[eventId].ticketPrice,
            events[eventId].totalTicketCount,
            events[eventId].ticketSoldCount,
            events[eventId].isOpen
        );
    }

    /// @notice Allows someone to buy tickets for a given event.
    function buyTickets(uint256 eventId, uint256 quantity)
        external
        payable
        isEventOpen(eventId)
        enoughFundsSent(eventId, quantity)
        enoughTicketsRemaining(eventId, quantity)
    {
        events[eventId].buyers[msg.sender] += quantity;
        events[eventId].ticketSoldCount += quantity;

        uint256 refundAmount = msg.value -
            quantity *
            events[eventId].ticketPrice;
        if (refundAmount > 0) {
            (bool refunded, ) = msg.sender.call{value: refundAmount}("");
            require(refunded, "Purchase refund failed");
        }

        emit TicketsBought(msg.sender, eventId, quantity);
    }

    /// @notice Allows a buyer to get a refund for some of his tickets.
    function getRefund(uint256 eventId, uint256 quantity)
        external
        ticketsWereBought(eventId, quantity)
    {
        events[eventId].buyers[msg.sender] -= quantity;
        events[eventId].ticketSoldCount -= quantity;

        (bool refunded, ) = msg.sender.call{
            value: quantity * events[eventId].ticketPrice
        }("");
        require(refunded, "Ticket refund failed");

        emit TicketsRefunded(msg.sender, eventId, quantity);
    }

    /// @notice Returns the number of tickets the sender has purchased.
    function getBuyerTicketCount(uint256 eventId)
        external
        view
        returns (uint256)
    {
        return events[eventId].buyers[msg.sender];
    }

    /// @notice Allows the contract owner to end an event.
    function endSale(uint256 eventId) external isOwner() isEventOpen(eventId) {
        events[eventId].isOpen = false;

        uint256 eventProceeds = events[eventId].ticketSoldCount *
            events[eventId].ticketPrice;
        (bool transfered, ) = msg.sender.call{value: eventProceeds}("");
        require(transfered, "Proceeds transfer failed");

        emit EventEnded(eventId, eventProceeds);
    }
}

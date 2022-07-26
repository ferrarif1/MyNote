// SPDX-License-Identifier: ISC
pragma solidity 0.8.6;

/// @notice This contract allows user to buy tickets for an event. It is also
/// possible to get a refund for tickets that were previously purchased. This
/// is were the contract is vulnerable to a reentrancy attack.
contract VulnerableTicketSale {

    /* State variables */

    uint256 public constant TICKET_PRICE = 0.1 ether;

    /// @notice Number of tickets sold for each buyer.
    mapping(address => uint256) private purchasedTickets;

    /* Custom errors & function modifiers */

    /// @notice Not enough funds were sent to buy tickets.
    error NotEnoughFundsSent();
    modifier enoughFundsSent(uint256 ticketQuantity) {
        if (msg.value < ticketQuantity * TICKET_PRICE) {
            revert NotEnoughFundsSent();
        }
        _;
    }

    /// @notice The quantity of tickets to be refunded exceeds the purchased quantity.
    error TicketsWereNotBought();
    modifier ticketsWereBought(uint256 ticketQuantity) {
        if (purchasedTickets[msg.sender] < ticketQuantity) {
            revert TicketsWereNotBought();
        }
        _;
    }

    /* Functions */

    /// @notice Allows the user to buy tickets for the event.
    function buyTickets(uint256 quantity)
        external
        payable
        enoughFundsSent(quantity)
    {
        purchasedTickets[msg.sender] += quantity;
    }

    /// @notice Allows a buyer to get a refund for the tickets he bought. This
    /// function is vulnerable to a reentrancy attack.
    function getRefund(uint256 quantity)
        external
        payable
        ticketsWereBought(quantity)
    {
        // If the address that calls this function is a smart contract, then
        // sending it Ether will execute its `receive' function which can
        // immediately call this function again. As the number of tickets sold
        // to the buyer has not yet been updated, the `ticketsWereBought' check
        // will pass, and more Ether will be sent to the malicious contract.
        (bool refunded, ) = msg.sender.call{value: quantity * TICKET_PRICE}("");
        require(refunded, "Ticket refund failed");

        // The number of tickets bought should be updated before refunding the
        // caller so as to respect the checks-effects-interactions pattern.
        // See: https://swcregistry.io/docs/SWC-107.
        //
        // As of Solidity 0.8.0, overflows and underflows revert. To continue
        // making the attack possible, we use unchecked to avoid the revert
        // when the underflow happens.
        unchecked {
            purchasedTickets[msg.sender] -= quantity;
        }
    }

    /// @dev Allows the contract to be funded during tests.
    receive() external payable {}
}

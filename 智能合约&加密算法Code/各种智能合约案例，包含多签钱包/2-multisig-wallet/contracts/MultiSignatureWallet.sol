// SPDX-License-Identifier: ISC
pragma solidity 0.8.4;

/// @notice This contract allows a set of owners (defined during the contract's initialization) to submit, confirm and
/// revoke transactions. A transaction is then executed if and only if it has been confirmed by a quorum of owners
/// (also set during the initialization).
///
/// It is possible to send a transaction either to an EOA or to a contract account. In the latter case, it is possible
/// to set the data field of the transaction (e.g. function signature and parameters). See the documentation of the
/// `ExecutionFailed` event to prevent the transaction from failing.
///
/// TODO
/// - use Solidity custom errors
/// - check cost of transaction if sent to an EOA vs contract account
/// - return confirmationCount in quorumObtainedFor
contract MultiSignatureWallet {

    /*
     * Structures
     */

    /// @notice A transaction to be submitted, confirmed and revoked.
    /// @param destination The destination of the transaction, i.e. EOA or contract account.
    /// @param value The amount of Ether to be sent.
    /// @param payload The data of the transaction.
    /// @param executed A flag indicating if the transaction has been executed or not.
    struct Transaction {
        address payable destination;
        uint256 value;
        bytes payload;
        bool executed;
    }

    /*
     * State variables
     */

    /// @notice The list of wallet owners.
    address[] public owners;

    /// @dev Cheaper than looping the array to know who's an owner.
    mapping(address => bool) public isOwner;

    /// @notice The quorum of owners needed to execute a transaction.
    uint256 public quorum;

    /// @notice A mapping of transaction ids to transactions.
    mapping(uint256 => Transaction) public transactions;

    /// @notice The number of transactions that have been submitted to the contract.
    uint256 public transactionCount;

    /// @notice For each transaction, a mapping of owners approving or not the transaction.
    mapping(uint256 => mapping(address => bool)) public confirmations;

    /*
     * Events
     */

    /// @notice An owner has submitted a new transaction.
    event Submitted(uint256 indexed transactionId);

    /// @notice An owner has confirmed an existing transaction.
    event Confirmed(address indexed sender, uint256 indexed transactionId);

    /// @notice An owner has revoked a transaction he had previously confirmed.
    event Revoked(address indexed sender, uint256 indexed transactionId);

    /// @notice The transaction was not executed because the quorum was not obtained.
    event QuorumNotObtained(uint256 indexed transactionId);

    /// @notice The transaction was not executed because the contract's balance is insufficient.
    event NotEnoughBalance(uint256 indexed transactionId);

    /// @notice The quorum has been obtained and the contract has enough balance but the transaction's execution has
    /// failed. Keep in mind the following:
    /// - if destination is an EOA:
    ///   - the payload is ignored and the value can be 0
    /// - if destination is a contract account:
    ///   - if value > 0 and payload is empty:   contract must have a receive Ether function or a payable fallback
    ///                                          function, if both then receive() will be executed
    ///   - if value > 0 and payload is invalid: contract must have a payable fallback function
    ///   - if value > 0 and payload is valid:   contract function that will be executed must be payable
    ///   - if value = 0 and payload is empty:   contract must have a receive Ether or a fallback function (need not be
    ///                                          payable)
    ///   - if value = 0 and payload is invalid: contract must have a fallback function (need not be payable)
    ///   - if value = 0 and payload is valid:   contract function that will be executed need not be payable
    event ExecutionFailed(uint256 indexed transactionId);

    /// @notice The transaction has been successfully executed.
    event Executed(uint256 indexed transactionId);

    /// @notice The contract has received Ether.
    event Deposit(address indexed sender, uint256 value);

    /*
     * Function modifiers
     */

    modifier notNull(address _address) {
        require(_address != address(0), "Address must not be null");
        _;
    }

    modifier senderIsAnOwner() {
        require(isOwner[msg.sender], "Sender must be an owner");
        _;
    }

    modifier senderHasConfirmed(uint256 _transactionId) {
        require(
            confirmations[_transactionId][msg.sender] == true,
            "Sender must have confirmed the transaction"
        );
        _;
    }

    modifier senderHasNotConfirmed(uint256 _transactionId) {
        require(
            confirmations[_transactionId][msg.sender] == false,
            "Sender must not have confirmed the transaction"
        );
        _;
    }

    modifier transactionExists(uint256 _transactionId) {
        require(_transactionId < transactionCount, "Transaction must exist");
        _;
    }

    modifier notExecuted(uint256 _transactionId) {
        require(
            transactions[_transactionId].executed == false,
            "Transaction must not have been executed"
        );
        _;
    }

    /*
     * Constructors
     */

    /// @notice Initializes the contract with the given list of owners and quorum.
    /// @param _owners The list of wallet owners.
    /// @param _quorum Quorum of owners for a transaction to be executed.
    constructor(address[] memory _owners, uint256 _quorum) {
        require(
            _quorum != 0 && _owners.length != 0 && _quorum < _owners.length,
            "Quorum and number of owners must be greater than 0"
        );

        owners = _owners;
        quorum = _quorum;

        for (uint256 i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
        }
    }

    /*
     * Functions
     */

    /// @notice Allows the contract to receive Ether and emit an event when it does.
    receive() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    /// @notice Allows an owner to submit a transaction. The transaction will be automatically confirmed.
    /// @param destination The address to which the transaction will be sent.
    /// @param value The amount of Ether to be sent with the transaction.
    /// @param payload The data of the transaction.
    /// @return transactionId Returns the transaction id.
    function submitTransaction(
        address payable destination,
        uint256 value,
        bytes calldata payload
    )
        external
        notNull(destination)
        senderIsAnOwner()
        returns (uint256 transactionId)
    {
        // store the submitted transaction
        transactionId = storeTransaction(destination, value, payload);

        // the sender also confirms it
        confirmTransaction(transactionId);
    }

    /// @notice Allows an owner to revoke a confirmation for a previously confirmed transaction.
    /// @param transactionId The id of the transaction to be revoked.
    function revokeConfirmation(uint256 transactionId)
        external
        transactionExists(transactionId)
        senderIsAnOwner()
        senderHasConfirmed(transactionId)
    {
        // sender revokes his previous confirmation
        confirmations[transactionId][msg.sender] = false;
        emit Revoked(msg.sender, transactionId);
    }

    /// @notice Allows an owner to confirm a transaction.
    /// @param transactionId The id of the transaction to be confirmed.
    function confirmTransaction(uint256 transactionId)
        public
        transactionExists(transactionId)
        senderIsAnOwner()
        senderHasNotConfirmed(transactionId)
    {
        // confirm transaction
        confirmations[transactionId][msg.sender] = true;
        emit Confirmed(msg.sender, transactionId);

        // attempt its execution
        executeTransaction(transactionId);
    }

    /// @notice Attemps to execute the given transaction.
    /// @param transactionId The id of the transaction to be executed.
    function executeTransaction(uint256 transactionId)
        public
        transactionExists(transactionId)
        notExecuted(transactionId)
    {
        if (!quorumObtainedFor(transactionId)) {
            emit QuorumNotObtained(transactionId);
            return;
        }

        Transaction storage t = transactions[transactionId];
        if (address(this).balance < t.value) {
            emit NotEnoughBalance(transactionId);
            return;
        }

        (bool success, ) = t.destination.call{value: t.value}(t.payload);
        if (success) {
            t.executed = true;
            emit Executed(transactionId);
        } else {
            emit ExecutionFailed(transactionId);
        }
    }

    /// @notice Checks if the quorum has been obtained for a given transaction.
    /// @param transactionId The id of the transaction to be checked.
    /// @return Returns true if the quorum has been obtained, false otherwise.
    function quorumObtainedFor(uint256 transactionId)
        private
        view
        returns (bool)
    {
        uint256 confirmationCount;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                confirmationCount++;
                if (confirmationCount == quorum) {
                    return true;
                }
            }
        }

        return false;
    }

    /// @notice Stores a new transaction to the contract's state.
    /// @param destination The destination address of the transaction.
    /// @param value The amount of Ether to be sent.
    /// @param payload The payload of the transaction.
    /// @return transactionId Returns the transaction id of the new transaction.
    function storeTransaction(
        address payable destination,
        uint256 value,
        bytes calldata payload
    ) private returns (uint256 transactionId) {
        // get next transaction id
        transactionId = transactionCount;

        // create new transaction and store it the mapping
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            executed: false,
            payload: payload
        });

        transactionCount++;
        emit Submitted(transactionId);
    }
}

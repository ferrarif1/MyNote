// SPDX-License-Identifier: ISC
pragma solidity 0.8.4;

/// @notice This contract acts as a simple bank, allowing users to enroll (i.e. create an account), to deposit and to
/// withdraw funds.
contract SimpleBank {

    /*
     * State variables
     */

    /// @notice Account balances of the clients of the bank.
    mapping(address => uint256) private balances;

    /// @notice The clients of the bank.
    mapping(address => bool) public enrolled;

    /*
     * Events
     */

    /// @notice A client has enrolled with the bank.
    event Enrolled(address indexed account);

    /// @notice A deposit was made.
    event DepositMade(address indexed account, uint256 amount);

    /// @notice A withdrawal was made.
    event WithdrawalMade(
        address indexed account,
        uint256 amount,
        uint256 newBalance
    );

    /*
     * Function modifiers
     */

    modifier senderMustBeEnrolled() {
        require(enrolled[msg.sender], "Sender must be enrolled");
        _;
    }

    /*
     * Functions
     */

    /// @notice Returns the balance of the sender's account.
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    /// @notice Enrolls the sender with the bank.
    /// @return The client's enrolled status.
    function enroll() external returns (bool) {
        if (!enrolled[msg.sender]) {
            enrolled[msg.sender] = true;
            emit Enrolled(msg.sender);
        }

        return true;
    }

    /// @notice Deposits Ether into the bank.
    /// @return The client's account balance after the deposit was made.
    function deposit()
        external
        payable
        senderMustBeEnrolled()
        returns (uint256)
    {
        balances[msg.sender] += msg.value;
        emit DepositMade(msg.sender, msg.value);
        return balances[msg.sender];
    }

    /// @notice Withdraws Ether from the bank.
    /// @param amount The amount of Ether to be withdrawn.
    /// @return newBalance The client's account balance after the withdrawal was made.
    function withdraw(uint256 amount)
        external
        senderMustBeEnrolled()
        returns (uint256 newBalance)
    {
        require(balances[msg.sender] >= amount, "Insufficient funds");

        balances[msg.sender] -= amount;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Withdrawal failed");

        newBalance = balances[msg.sender];
        emit WithdrawalMade(msg.sender, amount, newBalance);
    }
}

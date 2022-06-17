#
# Events

event ClientEnrolled:
    account: indexed(address)

event DepositMade:
    account: indexed(address)
    amount: uint256

event WithdrawalMade:
    account: indexed(address)
    amount: uint256
    newBalance: uint256

#
# State variables

clientBalances: public(HashMap[address, uint256])
enrolledStatus: public(HashMap[address, bool])
contractOwner: public(address)

#
# Functions

@external
def __init__():
    self.contractOwner = msg.sender


@external
@view
def accountBalance() -> uint256:
    """
    @notice Returns the client's account balance.
    """
    return self.clientBalances[msg.sender]


@external
def enroll() -> bool:
    """
    @notice Enrolls a client with the bank.
    @return The client's enrolled status.
    """
    assert not self.enrolledStatus[msg.sender], 'sender is already enrolled'

    self.enrolledStatus[msg.sender] = True
    log ClientEnrolled(msg.sender)

    return True


@external
@payable
def deposit() -> uint256:
    """
    @notice Deposits the received Ether into the client's account.
    @return The client's updated account balance.
    """
    assert self.enrolledStatus[msg.sender], 'sender not enrolled'

    self.clientBalances[msg.sender] += msg.value
    log DepositMade(msg.sender, msg.value)

    return self.clientBalances[msg.sender]


@external
def withdraw(amount: uint256) -> uint256:
    """
    @notice Withdraws the given Ether amount from the client's account.
    @return The client's updated account balance.
    """
    assert self.enrolledStatus[msg.sender], 'sender not enrolled'
    assert amount <= self.clientBalances[msg.sender], 'withdrawal amount greater than balance'

    self.clientBalances[msg.sender] -= amount
    send(msg.sender, amount)
    log WithdrawalMade(msg.sender, amount, self.clientBalances[msg.sender])

    return self.clientBalances[msg.sender]

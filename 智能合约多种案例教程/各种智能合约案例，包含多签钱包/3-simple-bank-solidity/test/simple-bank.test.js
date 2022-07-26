const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const SimpleBank = artifacts.require('SimpleBank.sol')

contract('SimpleBank', accounts => {

  const ENROLLED_EVENT = 'Enrolled'
  const DEPOSIT_MADE_EVENT = 'DepositMade'
  const WITHDRAWAL_MADE_EVENT = 'WithdrawalMade'

  const owner = accounts[0]
  const alice = accounts[1]
  const depositedAmount = new BN('2')

  let instance
  beforeEach(async () => {
    instance = await SimpleBank.new()
  })


  it('should mark addresses as enrolled', async () => {

    expectEvent(
      await instance.enroll({ from: alice }),
      ENROLLED_EVENT,
      { account: alice })

    assert.equal(
      await instance.enrolled(alice, { from: alice }),
      true,
      'enroll balance is incorrect, check balance method or constructor')
  })


  it('should not mark unenrolled users as enrolled', async () => {
    assert.equal(
      await instance.enrolled(owner, { from: owner }),
      false,
      'only enrolled users should be marked enrolled')
  })


  it('should deposit correct amount', async () => {

    await instance.enroll({ from: alice })
    await instance.deposit({ from: alice, value: depositedAmount })

    assert.equal(
      await instance.getBalance({ from: alice }),
      depositedAmount.toString(),
      'deposit amount incorrect, check deposit method')
  })


  it('should log a deposit event when a deposit is made', async () => {

    await instance.enroll({ from: alice })

    expectEvent(
      await instance.deposit({ from: alice, value: depositedAmount }),
      DEPOSIT_MADE_EVENT,
      { account: alice, amount: depositedAmount })
  })


  it('should withdraw correct amount', async () => {

    await instance.enroll({ from: alice })
    await instance.deposit({ from: alice, value: depositedAmount })
    await instance.withdraw(depositedAmount, { from: alice })

    assert.equal(
      await instance.getBalance({ from: alice }),
      0,
      'balance incorrect after withdrawal, check withdraw method')
  })


  it('should not be able to withdraw more than has been deposited', async () => {

    await instance.enroll({ from: alice })
    await instance.deposit({ from: alice, value: depositedAmount })

    await expectRevert(
      instance.withdraw(depositedAmount.add(new BN(1)), { from: alice }),
      'Insufficient funds')
  })


  it('should emit the appropriate event when a withdrawal is made', async () => {

    await instance.enroll({ from: alice })
    await instance.deposit({ from: alice, value: depositedAmount })

    expectEvent(
      await instance.withdraw(depositedAmount, { from: alice }),
      WITHDRAWAL_MADE_EVENT,
      { account: alice, newBalance: new BN(0), amount: depositedAmount })
  })
})

const { expectEvent, ether } = require('@openzeppelin/test-helpers')
const SimpleBank = artifacts.require('SimpleBank')

contract('SimpleBank', async accounts => {

  const owner = accounts[0]
  const alice = accounts[1]
  const bob = accounts[2]
  const depositAmount = ether('0.1')

  let instance
  beforeEach(async () => {
    instance = await SimpleBank.new({ from: owner })
  })


  it('should set constructor value', async () => {
    const actualOwner = await instance.contractOwner()
    assert.strictEqual(actualOwner, owner)
  })


  it('should mark addresses as enrolled', async () => {

    await instance.enroll({ from: alice })

    const aliceEnrolled = await instance.enrolledStatus(alice)
    assert.equal(aliceEnrolled, true, 'Alice should be enrolled')

    const ownerEnrolled = await instance.enrolledStatus(owner)
    assert.equal(ownerEnrolled, false, 'Owner should not be enrolled')
  })


  it('should deposit correct amount', async () => {

    await instance.enroll({ from: bob })

    const receipt = await instance.deposit({ from: bob, value: depositAmount })
    const balance = await instance.accountBalance({ from: bob })

    assert.equal(balance, depositAmount.toString(), 'Bob\'s balance is incorrect')
    expectEvent(receipt, 'DepositMade', { account: bob, amount: depositAmount })
  })


  it('should withdraw correct amount', async () => {

    const initialAmount = ether('0')

    await instance.enroll({ from: alice })
    await instance.deposit({ from: alice, value: depositAmount })

    const receipt = await instance.withdraw(depositAmount, { from: alice })
    const balance = await instance.accountBalance({ from: alice })

    assert.equal(balance.toString(), initialAmount.toString(), 'New balance is incorrect')
    expectEvent(receipt, 'WithdrawalMade', { account: alice, newBalance: initialAmount, amount: depositAmount })
  })
})

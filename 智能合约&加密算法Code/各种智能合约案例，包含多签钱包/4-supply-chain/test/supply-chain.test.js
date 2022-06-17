const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const SupplyChain = artifacts.require('SupplyChain')

contract('SupplyChain', accounts => {

  const FOR_SALE_EVENT = 'ForSale'
  const SOLD_EVENT = 'Sold'
  const SHIPPED_EVENT = 'Shipped'
  const RECEIVED_EVENT = 'Received'

  const alice = accounts[1]
  const bob = accounts[2]
  const emptyAddress = '0x0000000000000000000000000000000000000000'

  const price = '1000'
  const excessAmount = '2000'
  const name = 'my book'

  let instance
  beforeEach(async () => {
    instance = await SupplyChain.new()
  })


  it('should add an item with the provided name and price', async () => {

    await instance.addItem(name, price, { from: alice })

    const item = await instance.fetchItem(0)
    assert.equal(item.name, name, 'name does not match')
    assert.equal(item.price, price, 'price does not match')
    assert.equal(item.state, 0, 'state should be ForSale')
    assert.equal(item.seller, alice, 'seller should be Alice')
    assert.equal(item.buyer, emptyAddress, 'buy should not be set')
  })


  it('should emit a ForSale event when an item is added', async () => {
    expectEvent(
      await instance.addItem(name, price, { from: alice }),
      FOR_SALE_EVENT,
      { sku: '0' })
  })


  it('should allow someone to purchase an item and update state accordingly', async () => {

    await instance.addItem(name, price, { from: alice })
    const aliceBalanceBefore = await web3.eth.getBalance(alice)
    const bobBalanceBefore = await web3.eth.getBalance(bob)

    await instance.buyItem(0, { from: bob, value: excessAmount })
    const aliceBalanceAfter = await web3.eth.getBalance(alice)
    const bobBalanceAfter = await web3.eth.getBalance(bob)

    const item = await instance.fetchItem(0)

    assert.equal(item.state, 1, 'state should be Sold')
    assert.equal(item.buyer, bob, 'buyer should be Bob')

    assert.equal(
      aliceBalanceAfter,
      new BN(aliceBalanceBefore).add(new BN(price)).toString(),
      'Alice\'s balance should have increased by the price of the item')

    assert.isBelow(
      Number(bobBalanceAfter),
      bobBalanceBefore - price,
      'Bob\'s balance should have been reduced by more than the price of the item (including gas costs)')
  })


  it('should error when not enough value is sent when purchasing an item', async () => {

    await instance.addItem(name, price, { from: alice })

    await expectRevert(
      instance.buyItem(0, { from: bob, value: 1 }),
      'Insufficient payed amount')
  })


  it('should emit Sold event when and item is purchased', async () => {

    await instance.addItem(name, price, { from: alice })

    expectEvent(
      await instance.buyItem(0, { from: bob, value: excessAmount }),
      SOLD_EVENT,
      { sku: '0' })
  })


  it('should revert when someone that is not the seller tries to call shipItem()', async () => {

    await instance.addItem(name, price, { from: alice })
    await instance.buyItem(0, { from: bob, value: price })

    await expectRevert(
      instance.shipItem(0, { from: bob }),
      'Caller must be the seller')
  })


  it('should allow the seller to mark the item as shipped', async () => {

    await instance.addItem(name, price, { from: alice })
    await instance.buyItem(0, { from: bob, value: excessAmount })
    await instance.shipItem(0, { from: alice })

    const item = await instance.fetchItem(0)
    assert.equal(item.state, 2, 'state should be Shipped')
  })


  it('should emit a Shipped event when an item is shipped', async () => {

    await instance.addItem(name, price, { from: alice })
    await instance.buyItem(0, { from: bob, value: excessAmount })

    expectEvent(
      await instance.shipItem(0, { from: alice }),
      SHIPPED_EVENT,
      { sku: '0' })
  })


  it('should allow the buyer to mark the item as received', async () => {

    await instance.addItem(name, price, { from: alice })
    await instance.buyItem(0, { from: bob, value: excessAmount })
    await instance.shipItem(0, { from: alice })
    await instance.receiveItem(0, { from: bob })

    const item = await instance.fetchItem(0)
    assert.equal(item.state, 3, 'state should be Received')
  })


  it('should revert if an address other than the buyer calls receiveItem()', async () => {

    await instance.addItem(name, price, { from: alice })
    await instance.buyItem(0, { from: bob, value: excessAmount })
    await instance.shipItem(0, { from: alice })

    await expectRevert(
      instance.receiveItem(0, { from: alice }),
      'Caller must be the buyer')
  })


  it('should emit a Received event when an item is received', async () => {

    await instance.addItem(name, price, { from: alice })
    await instance.buyItem(0, { from: bob, value: excessAmount })
    await instance.shipItem(0, { from: alice })

    expectEvent(
      await instance.receiveItem(0, { from: bob }),
      RECEIVED_EVENT,
      { sku: '0' })
  })
})

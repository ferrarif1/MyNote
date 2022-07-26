const { balance, constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const MultiSignatureWallet = artifacts.require('MultiSignatureWallet')
const SimpleStorage = artifacts.require('SimpleStorage')


contract('MultiSignatureWallet', accounts => {

  const SUBMITTED = 'Submitted'
  const CONFIRMED = 'Confirmed'
  const REVOKED = 'Revoked'
  const EXECUTED = 'Executed'
  const QUORUM_NOT_OBTAINED = 'QuorumNotObtained'
  const NOT_ENOUGH_BALANCE = 'NotEnoughBalance'
  const DEPOSIT = 'Deposit'


  const _0_ETHER = '0'
  const _0_01_ETH = web3.utils.toWei('0.01')

  // this payload will execute the set function of the destination contract
  // with the given parameter
  const PAYLOAD_PARAMETER = 1337
  const PAYLOAD = web3.eth.abi.encodeFunctionCall({
    name: 'set',
    type: 'function',
    inputs: [{
      type: 'uint256',
      name: '_data'
    }]
  }, [PAYLOAD_PARAMETER])

  const TX_ID_0 = '0'
  const SIMPLE_TX = {
    destination: SimpleStorage.address,
    value: _0_01_ETH,
    payload: PAYLOAD
  }


  const quorum = 2
  const owners = accounts.slice(1, 4)

  const [firstOwner, secondOwner] = owners
  const creator = accounts[0]
  const notAnOwner = accounts[9]


  let walletInstance
  beforeEach(async () => {
    walletInstance = await MultiSignatureWallet.new(owners, quorum, { from: creator })
  })


  it('should receive Ether', async () => {

    expectEvent(
      await walletInstance.send(_0_01_ETH, { from: notAnOwner }),
      DEPOSIT,
      { sender: notAnOwner, value: _0_01_ETH })

    assert.equal(
      await web3.eth.getBalance(walletInstance.address),
      _0_01_ETH,
      'Balance should have correct value')
  })


  describe('Initiliazing the contract', () => {

    it('should set the owners and the quorum', async () => {

      for (const i in owners) {
        assert.equal(await walletInstance.isOwner(owners[i]), true, `Account at position ${i} should be owner`)
        assert.equal(await walletInstance.owners(i), owners[i], `Owner at position ${i} should be correct`)
      }

      assert.equal(await walletInstance.quorum(), quorum, 'Quorum should have correct value')
    })
  })


  describe('Submitting a transaction', () => {


    it('should be allowed for owners', async () => {

      const expectedTxCount = 1
      const receipt = await walletInstance.submitTransaction(
        SIMPLE_TX.destination, SIMPLE_TX.value, SIMPLE_TX.payload,
        { from: firstOwner })

      // check for expected events
      expectEvent(receipt, SUBMITTED, { transactionId: TX_ID_0 }) // TODO rename events in .sol, add constant for event names
      expectEvent(receipt, CONFIRMED, { sender: firstOwner, transactionId: TX_ID_0 })

      // check for transaction count
      assert.equal(
        await walletInstance.transactionCount(),
        expectedTxCount,
        'Transaction count should be correct')

      // check for transaction value
      const tx = await walletInstance.transactions(TX_ID_0)
      assert.equal(tx.destination, SIMPLE_TX.destination, 'Destination should be correct')
      assert.equal(tx.value, SIMPLE_TX.value, 'Sent value should be correct')
      assert.equal(tx.payload, SIMPLE_TX.payload, 'Payload should be correct')
      assert.equal(tx.executed, false, 'Tx should not have been executed')

      // check for owner confirmation
      assert.isTrue(
        await walletInstance.confirmations(TX_ID_0, firstOwner),
        'Owner should have confirmed his transaction')
    })


    it('should not be allowed for non-owners', async () => {
      await expectRevert(
        walletInstance.submitTransaction(SIMPLE_TX.destination, SIMPLE_TX.value, SIMPLE_TX.payload, { from: notAnOwner }),
        'Sender must be an owner')
    })


    it('should not be allowed to a zero destination address', async () => {
      await expectRevert(
        walletInstance.submitTransaction(constants.ZERO_ADDRESS, SIMPLE_TX.value, SIMPLE_TX.payload, { from: firstOwner }),
        'Address must not be null')
    })
  })


  describe('Revoking a confirmation', () => {

    it('should not be allowed for a non-existent transaction', async () => {
      await expectRevert(
        walletInstance.revokeConfirmation(1, { from: firstOwner }),
        'Transaction must exist')
    })


    it('should not be allowed for a non-owner', async () => {

      await walletInstance.submitTransaction(
        SIMPLE_TX.destination, SIMPLE_TX.value, SIMPLE_TX.payload, { from: firstOwner })

      await expectRevert(
        walletInstance.revokeConfirmation(0, { from: notAnOwner }),
        'Sender must be an owner')
    })


    it('should not be allowed for an owner not having confirmed the transaction', async () => {

      await walletInstance.submitTransaction(
        SIMPLE_TX.destination, SIMPLE_TX.value, SIMPLE_TX.payload, { from: firstOwner })

      await expectRevert(
        walletInstance.revokeConfirmation(0, { from: secondOwner }),
        'Sender must have confirmed the transaction')
    })


    it('should be allowed for an owner having already confirmed the transaction', async () => {

      await walletInstance.submitTransaction(
        SIMPLE_TX.destination, SIMPLE_TX.value, SIMPLE_TX.payload, { from: firstOwner })

      expectEvent(
        await walletInstance.revokeConfirmation(TX_ID_0, { from: firstOwner }),
        REVOKED,
        { sender: firstOwner, transactionId: TX_ID_0 })

      assert.isFalse(
        await walletInstance.confirmations(TX_ID_0, firstOwner),
        'Transaction should have been revoked')
    })
  })


  describe('Confirming a transaction', () => {

    it('should not be allowed for a non-existent transaction', async () => {
      await expectRevert(
        walletInstance.confirmTransaction(1, { from: firstOwner }),
        'Transaction must exist')
    })


    it('should not be allowed for a non-owner', async () => {

      await walletInstance.submitTransaction(
        SIMPLE_TX.destination, SIMPLE_TX.value, SIMPLE_TX.payload, { from: firstOwner })

      await expectRevert(
        walletInstance.confirmTransaction(TX_ID_0, { from: notAnOwner }),
        'Sender must be an owner')
    })


    it('should not be allowed for an owner having already confirmed the transaction', async () => {

      await walletInstance.submitTransaction(
        SIMPLE_TX.destination, SIMPLE_TX.value, SIMPLE_TX.payload, { from: firstOwner })

      await expectRevert(
        walletInstance.confirmTransaction(TX_ID_0, { from: firstOwner }),
        'Sender must not have confirmed the transaction')
    })


    it('should be allowed for an owner not having confirmed the transaction', async () => {

      await walletInstance.submitTransaction(
        SIMPLE_TX.destination, SIMPLE_TX.value, SIMPLE_TX.payload, { from: firstOwner })

      expectEvent(
        await walletInstance.confirmTransaction(TX_ID_0, { from: secondOwner }),
        CONFIRMED,
        { sender: secondOwner, transactionId: TX_ID_0 })

      assert.isTrue(
        await walletInstance.confirmations(TX_ID_0, secondOwner),
        'Transaction should have been revoked')
    })
  })


  describe('Executing a transaction', () => {

    it('should not be allowed for a non-existent transaction', async () => {
      await expectRevert(
        walletInstance.executeTransaction(1, { from: firstOwner }),
        'Transaction must exist')
    })


    it('should not be allowed for an already executed transaction', async () => {

      await walletInstance.submitTransaction(
        SIMPLE_TX.destination, _0_ETHER, SIMPLE_TX.payload, { from: firstOwner })

      await walletInstance.confirmTransaction(TX_ID_0, { from: secondOwner })

      await expectRevert(
        walletInstance.executeTransaction(TX_ID_0, { from: notAnOwner }),
        'Transaction must not have been executed')
    })


    it('should not succeed if the quorum is not reached', async () => {

      await walletInstance.submitTransaction(
        SIMPLE_TX.destination, SIMPLE_TX.value, SIMPLE_TX.payload, { from: firstOwner })

      expectEvent(
        await walletInstance.executeTransaction(TX_ID_0, { from: notAnOwner }),
        QUORUM_NOT_OBTAINED,
        { transactionId: TX_ID_0 })
    })


    it('should not succeed if the balance is insufficient', async () => {

      await walletInstance.submitTransaction(
        SIMPLE_TX.destination, SIMPLE_TX.value, SIMPLE_TX.payload, { from: firstOwner })

      expectEvent(
        await walletInstance.confirmTransaction(TX_ID_0, { from: secondOwner }),
        NOT_ENOUGH_BALANCE,
        { transactionId: TX_ID_0 })
    })


    it('should send Ether and payload to destination', async () => {

      const destinationBalance = await balance.current(SIMPLE_TX.destination)

      // send some Ether first to the multisig wallet and submit transaction
      await walletInstance.send(SIMPLE_TX.value, { from: notAnOwner })
      await walletInstance.submitTransaction(SIMPLE_TX.destination, SIMPLE_TX.value, SIMPLE_TX.payload, { from: firstOwner })

      // confirm transaction and expect it's execution
      expectEvent(
        await walletInstance.confirmTransaction(TX_ID_0, { from: secondOwner }),
        EXECUTED,
        { transactionId: TX_ID_0 })

      // check balances
      assert.equal(
        (await balance.current(SIMPLE_TX.destination)).toString(),
        destinationBalance.add(web3.utils.toBN(SIMPLE_TX.value)).toString(),
        'Destination balance should be correct')

      assert.equal(
        await balance.current(walletInstance.address),
        _0_ETHER,
        'Multisig wallet balance should be correct')

      // check destination contract state
      assert.equal(
        await (await SimpleStorage.deployed()).data(),
        PAYLOAD_PARAMETER,
        'Value of the data state variable should be correct')

      assert.equal(
        await (await SimpleStorage.deployed()).caller(),
        walletInstance.address,
        'Value of the caller state variable should be correct')
    })
  })
})

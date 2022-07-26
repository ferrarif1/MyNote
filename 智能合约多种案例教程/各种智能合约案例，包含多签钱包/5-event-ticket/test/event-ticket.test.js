const { BN, balance, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const EventTicket = artifacts.require('EventTicket')

const computeFee = async receipt =>
  new BN(receipt.gasUsed * (await web3.eth.getGasPrice()))


contract('EventTicket', accounts => {

  const EVENT_ADDED_EVENT = 'EventAdded'
  const EVENT_ENDED_EVENT = 'EventEnded'
  const TICKETS_BOUGHT_EVENT = 'TicketsBought'
  const TICKETS_REFUNDED_EVENT = 'TicketsRefunded'


  const contractOwner = accounts[9]
  const firstAccount = accounts[3]
  const secondAccount = accounts[4]

  const event1 = {
    description: 'my first event',
    website: 'https://event-one.com',
    ticketPrice: '11111',
    totalTicketCount: '100'
  }

  const event2 = {
    description: 'my second event',
    website: 'https://event-two.com',
    ticketPrice: '22222',
    totalTicketCount: '200'
  }

  const event3 = {
    description: 'my third event',
    website: 'https://event-third.com',
    ticketPrice: '33333',
    totalTicketCount: '300'
  }


  let instance
  beforeEach(async () => {
    instance = await EventTicket.new({ from: contractOwner })
  })


  describe('Setup', async () => {

    it('owner should be set to the deploying address', async () => {
      assert.equal(
        await instance.owner(),
        contractOwner,
        'the deploying address should be the owner')
    })
  })


  describe('Functions', () => {

    describe('addEvent()', async () => {

      it('only the owner should be able to add an event', async () => {
        await expectRevert.unspecified(
          instance.addEvent(...Object.values(event1), { from: firstAccount }))
      })


      it('adding an event should emit an event with the provided event details', async () => {
        expectEvent(
          await instance.addEvent(...Object.values(event1), { from: contractOwner }),
          EVENT_ADDED_EVENT,
          { ...event1, eventId: '0' })
      })
    })


    describe('readEvent()', async () => {

      it('providing the event id should return the correct event details', async () => {

        await instance.addEvent(...Object.values(event1), { from: contractOwner })
        const { description, website, ticketPrice, totalTicketCount, ticketSoldCount, isOpen } = await instance.readEvent(0)

        assert.equal(description, event1.description, 'description should match')
        assert.equal(website, event1.website, 'website should match')
        assert.equal(ticketPrice, event1.ticketPrice, 'ticket price should match')
        assert.equal(totalTicketCount, event1.totalTicketCount, 'total ticket count should match')
        assert.equal(ticketSoldCount, 0, 'ticket sales should be 0')
        assert.equal(isOpen, true, 'event should be open')
      })
    })


    describe('buyTickets()', async () => {

      it('should not be possible to buy tickets for closed events', async () => {
        await expectRevert.unspecified(
          instance.buyTickets(1, 100, { from: firstAccount, value: 1000 }))
      })

      it('should be possible to buy tickets for open events', async () => {

        await instance.addEvent(...Object.values(event2), { from: contractOwner })

        const ticketsToBuy = 5
        expectEvent(
          await instance.buyTickets(0, ticketsToBuy, { from: firstAccount, value: ticketsToBuy * event2.ticketPrice }),
          TICKETS_BOUGHT_EVENT,
          { buyer: firstAccount, eventId: '0', quantity: new BN(ticketsToBuy) })

        const { ticketSoldCount } = await instance.readEvent(0)
        assert.equal(ticketSoldCount, ticketsToBuy, `the number of ticket sold should be ${ticketsToBuy}`)
      })


      it('tickets should only be able to be purchased when enough value is sent with the transaction', async () => {

        await instance.addEvent(...Object.values(event3), { from: contractOwner })

        const ticketsToBuy = 5
        await expectRevert.unspecified(
          instance.buyTickets(0, ticketsToBuy, { from: firstAccount, value: ticketsToBuy * event3.ticketPrice - 1 }))
      })


      it('tickets should only be able to be purchased when there are enough tickets remaining', async () => {

        const ticketsToBuy = Math.floor(event1.totalTicketCount / 2) + 1
        await instance.addEvent(...Object.values(event1), { from: contractOwner })
        await instance.buyTickets(0, ticketsToBuy, { from: firstAccount, value: ticketsToBuy * event1.ticketPrice })

        await expectRevert.unspecified(
          instance.buyTickets(0, ticketsToBuy, { from: secondAccount, value: ticketsToBuy * event1.ticketPrice }))
      })
    })


    describe('getRefund()', async () => {

      it('should not refund if account has not purchased the tickets', async () => {

        const ticketsToBuy = 10
        await instance.addEvent(...Object.values(event1), { from: contractOwner })
        await instance.buyTickets(0, ticketsToBuy, { from: secondAccount, value: event1.ticketPrice * ticketsToBuy })

        await expectRevert.unspecified(
          instance.getRefund(0, ticketsToBuy + 1, { from: secondAccount }))
      })


      it('should refund if account has purchased the tickets', async () => {

        const ticketsToBuy = new BN('10')
        const ticketsToRefund = new BN('6')
        const ticketsBought = ticketsToBuy.sub(ticketsToRefund)
        const ticketPrice = new BN(event2.ticketPrice)

        // add an event
        await instance.addEvent(...Object.values(event2), { from: contractOwner })

        // buy tickets and get a refund for some of them
        const balanceBefore = await balance.current(secondAccount)
        const buyTx = await instance.buyTickets(0, ticketsToBuy, { from: secondAccount, value: ticketsToBuy.mul(ticketPrice) })
        const refundTx = await instance.getRefund(0, ticketsToRefund, { from: secondAccount })
        const balanceAfter = await balance.current(secondAccount)

        // check event was logged
        expectEvent(
          refundTx.receipt,
          TICKETS_REFUNDED_EVENT,
          { buyer: secondAccount, eventId: '0', quantity: ticketsToRefund })

        // check number of tickets bought was correctly updated
        assert.equal(
          await instance.getBuyerTicketCount(0, { from: secondAccount }),
          ticketsBought.toString(),
          'quantity of tickets bought is incorrect'
        )

        // check buyer was correctly refunded
        const buyTxFee = await computeFee(buyTx.receipt)
        const refundTxFee = await computeFee(refundTx.receipt)
        const expectedBalance = balanceBefore.sub(buyTxFee).sub(refundTxFee).sub(ticketsBought.mul(ticketPrice))

        assert.equal(
          balanceAfter.toString(),
          expectedBalance.toString(),
          'buyer should be fully refunded when calling getRefund()')
      })
    })


    describe('getBuyerTicketCount()', async () => {

      it('providing an event id to getBuyerTicketCount() should tell an account how many tickets they have purchased', async () => {

        const ticketsToBuy = 3
        await instance.addEvent(...Object.values(event3), { from: contractOwner })
        await instance.buyTickets(0, ticketsToBuy, { from: secondAccount, value: event3.ticketPrice * ticketsToBuy })

        assert.equal(
          await instance.getBuyerTicketCount(0, { from: secondAccount }),
          ticketsToBuy,
          'getBuyerTicketCount() should return the number of tickets the msg.sender has purchased.')
      })
    })


    describe('endSale()', async () => {

      it('should not allow non-owner to end the event', async () => {
        await instance.addEvent(...Object.values(event2), { from: contractOwner })
        await expectRevert.unspecified(
          instance.endSale(0, { from: firstAccount }))

        // const txResult = await instance.endSale(0, { from: contractOwner })
        // const eventData = await instance.readEvent(0)

        // assert.equal(eventData['4'], false, 'The event isOpen variable should be marked false.')
      })


      it('endSale() should emit an event with information about how much ETH was sent to the contract owner', async () => {

        const ticketsToBuy = 3
        await instance.addEvent(...Object.values(event1), { from: contractOwner })
        await instance.buyTickets(0, ticketsToBuy, { from: secondAccount, value: event1.ticketPrice * ticketsToBuy })

        expectEvent(
          await instance.endSale(0, { from: contractOwner }),
          EVENT_ENDED_EVENT,
          { eventId: '0', proceeds: new BN(event1.ticketPrice * ticketsToBuy) })
      })
    })
  })
})

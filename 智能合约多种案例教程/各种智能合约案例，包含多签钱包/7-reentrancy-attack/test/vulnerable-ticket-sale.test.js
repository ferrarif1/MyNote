const { BN, balance, ether } = require('@openzeppelin/test-helpers')
const VulnerableTicketSale = artifacts.require('VulnerableTicketSale')
const AttackContract = artifacts.require('MaliciousBuyer')

const computeFee = async receipt =>
  new BN(receipt.gasUsed * (await web3.eth.getGasPrice()))


contract('VulnerableTicketSale', accounts => {

  const TICKET_PRICE = ether('0.1')

  const eve = accounts[1]
  const bob = accounts[2]

  let vulnerableTicketSale
  let attackContract


  before(async () => {

    // get address of vulnerable contract and send some funds
    vulnerableTicketSale = await VulnerableTicketSale.deployed()
    await vulnerableTicketSale.send(ether('1.234'), { from: bob })

    // deploy the attack contract using the attacker's account
    attackContract = await AttackContract.new(vulnerableTicketSale.address, { from: eve })
  })


  it('should have most of its funds stolen', async () => {

    // get balances before the attack and compute the expected amount of stolen funds
    const vulnerableBalance = await balance.current(vulnerableTicketSale.address)
    const expectedStolenFunds = vulnerableBalance.sub(vulnerableBalance.mod(TICKET_PRICE))
    const eveBalanceBefore = await balance.current(eve)

    // execute the attack
    const tx = await attackContract.stealFunds({ from: eve, value: TICKET_PRICE })

    // get balance after the attack and compute the actual amount of stolen funds
    const eveBalanceAfter = await balance.current(eve)
    const stolenFunds = eveBalanceAfter.sub(eveBalanceBefore).add(await computeFee(tx.receipt))

    assert.equal(stolenFunds.toString(), expectedStolenFunds.toString(), 'funds should have been stolen')
  })
})

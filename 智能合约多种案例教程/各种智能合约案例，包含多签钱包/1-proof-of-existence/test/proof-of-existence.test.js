const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const ProofOfExistence = artifacts.require('ProofOfExistence')


contract('ProofOfExistence', () => {

  const document = 'Lorem ipsum'

  let instance
  beforeEach(async () => {
    instance = await ProofOfExistence.new()
  })


  it('should notarize a given document', async () => {

    assert.isFalse(await instance.wasNotarized(document))

    expectEvent(
      await instance.notarize(document),
      'DocumentNotarized',
      { proof: web3.utils.soliditySha3(document) })

    assert.isTrue(await instance.wasNotarized(document))
  })


  it('should not notarize an already notarized document', async () => {
    await instance.notarize(document)
    await expectRevert.unspecified(
      instance.notarize(document))
  })
})

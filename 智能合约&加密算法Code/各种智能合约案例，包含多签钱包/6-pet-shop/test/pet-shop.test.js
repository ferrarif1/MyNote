const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')
const { ZERO_ADDRESS } = require('@openzeppelin/test-helpers/src/constants')
const PetShop = artifacts.require('PetShop')

contract('PetShop', accounts => {

  const owner = accounts[0]
  const anAdopter = accounts[1]
  const anotherAdopter = accounts[2]

  const PET_ADOPTED_EVENT = 'PetAdopted'


  let instance
  beforeEach(async () => {
    instance = await PetShop.new()
  })


  it('should allow adoption of a pet', async () => {

    const petId = 2
    expectEvent(
      await instance.adopt(petId, { from: anAdopter }),
      PET_ADOPTED_EVENT,
      { petId: new BN(petId), owner: anAdopter })

    const actualAdopter = await instance.adopters(petId)
    assert.equal(actualAdopter, anAdopter, `adopter should be ${anAdopter}`)
  })


  it('should not allow the adoption of a pet that does not exist', async () => {
    await expectRevert.unspecified(
      instance.adopt(256, { from: anAdopter }))
  })


  it('should not allow the adoption of an already adopted pet', async () => {

    const petId = 5
    await instance.adopt(petId, { from: anAdopter })

    await expectRevert.unspecified(
      instance.adopt(petId, { from: anotherAdopter }))
  })


  it('should allow the owner to reset the contract', async () => {

    const petId = 5
    await instance.adopt(petId, { from: anAdopter })
    await instance.adopt(petId + 1, { from: anotherAdopter })

    await instance.reset({ from: owner })

    const adopters = await instance.getAdopters()
    assert.isTrue(adopters.every(e => e == ZERO_ADDRESS))
  })
})

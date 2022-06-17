const MultiSignatureWallet = artifacts.require('MultiSignatureWallet')
const SimpleStorage = artifacts.require('SimpleStorage')

module.exports = function (deployer, _, accounts) {
  // deploy multisig wallet with 3 owners and a quorum of 2
  deployer.deploy(MultiSignatureWallet, accounts.slice(1, 4), 2)
  deployer.deploy(SimpleStorage)
}

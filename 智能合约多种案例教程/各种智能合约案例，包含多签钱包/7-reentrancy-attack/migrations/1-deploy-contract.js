const VulnerableTicketSale = artifacts.require('VulnerableTicketSale')

module.exports = function (deployer) {
  deployer.deploy(VulnerableTicketSale)
}

const EventTicket = artifacts.require('EventTicket')

module.exports = function (deployer) {
  deployer.deploy(EventTicket)
}

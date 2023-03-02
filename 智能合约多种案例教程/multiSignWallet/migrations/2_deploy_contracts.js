var ZeroToken = artifacts.require("./ZeroToken.sol");

module.exports = function(deployer) {
  // Deploy the METoken contract as our only task
  deployer.deploy(ZeroToken);
};
const TraceSource = artifacts.require("TraceSource");

module.exports = function (deployer) {
  deployer.deploy(TraceSource);
};
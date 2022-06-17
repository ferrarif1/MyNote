const v1 = artifacts.require('V1');
const v2 = artifacts.require('V2');
const vproxy = artifacts.require('vProxy');

module.exports = async function (deployer) {
  await deployer.deploy(v1);
  await deployer.deploy(v2);

  const v1Ddeployed = await v1.deployed();
  await deployer.deploy(vproxy, v1Ddeployed.address)
};

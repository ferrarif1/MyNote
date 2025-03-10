const hre = require('hardhat');

async function getChainId() {
  const chainIdHex = await hre.network.provider.send('eth_chainId', []);

  const chainId = new hre.web3.utils.BN(chainIdHex, 'hex')
 
  return chainId;
}

module.exports = {
  getChainId,
};

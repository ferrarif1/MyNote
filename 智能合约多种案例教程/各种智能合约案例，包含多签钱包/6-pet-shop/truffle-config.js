const HDWalletProvider = require('@truffle/hdwallet-provider')
const fs = require('fs')

const [mnemonic, infuraKey] = fs.readFileSync('../.secret').toString().split('\n')
const infuraURL = `https://ropsten.infura.io/v3/${infuraKey}`

module.exports = {

  networks: {
    development: {
      host: '127.0.0.1',
      port: 7545,
      network_id: '*',
    },

    ropsten: {
      provider: () => new HDWalletProvider(mnemonic, infuraURL),
      network_id: 3,
      gas: 5500000
    },
  },

  compilers: {
    solc: {
      version: '0.8.5'
    }
  },
}

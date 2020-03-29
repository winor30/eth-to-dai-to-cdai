const Web3 = require('web3');
const HDWalletProvider = require('truffle-hdwallet-provider');
const NETWORK = process.env.NETWORK;
const infuraKey = process.env.INFURA_KEY;
const mnemonic = process.env.MNEMONIC;
const infuraUrl = `https://${NETWORK}.infura.io/v3/${infuraKey}`;

module.exports = () => {
  console.log({NETWORK})
  switch (NETWORK) {
    case 'development':
      return new Web3('http://127.0.0.1:8545');
    case 'ropsten':
    case 'rinkeby':
    case 'mainnet': {
      const web3 = new Web3();
      const provider = mnemonic ? new HDWalletProvider(mnemonic, infuraUrl) : web3.currentProvider;
      web3.setProvider(provider);
      return web3;
    }

  }
}

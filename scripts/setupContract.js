require('dotenv').config();

const createWeb3 = require('./web3');
const web3 = createWeb3();

// rinkeby
// https://rinkeby.etherscan.io/token/0x5592ec0cfb4dbc12d3ab100b257153436a1f0fea?a=0x6d7f0754ffeb405d23c51ce938289d4835be3b14
const daiAddress = '0x5592ec0cfb4dbc12d3ab100b257153436a1f0fea';
// https://compound.finance/developers#networks
const cDaiAddress = '0x6d7f0754ffeb405d23c51ce938289d4835be3b14';
// https://rinkeby.etherscan.io/address/0xaf51baaa766b65e8b3ee0c2c33186325ed01ebd5
const uniswapAddress = '0xaF51BaAA766b65E8B3Ee0C2c33186325ED01eBD5';
// deployed address for <root dir>/contracts/Eth2Dai.sol
const ethToDaiAddress = `${process.env.ETH_TO_DAI}`;

const { abi: ethToDaiAbi } = require('../build/contracts/Eth2Dai.json');
const ethToDai = new web3.eth.Contract(ethToDaiAbi, ethToDaiAddress);

const { abi: daiAbi } = require('../node_modules/@openzeppelin/contracts/build/contracts/ERC20.json')
const dai = new web3.eth.Contract(daiAbi, daiAddress)
const cDai = new web3.eth.Contract(daiAbi, cDaiAddress)

const uniswapAbi = require('./abi/uniswap.json')
const uniswap = new web3.eth.Contract(uniswapAbi, uniswapAddress);

module.exports = {
  ethToDai,
  uniswap,
  web3,
  dai,
  cDai,
}

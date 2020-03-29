const {
  ethToDai,
  uniswap,
  web3,
  dai,
  cDai
} = require('./setupContract');

const showBalances = async (myWalletAddress) => {
  const balanceEth = await web3.eth.getBalance(myWalletAddress);
  console.log('eth balance', web3.utils.fromWei(`${balanceEth}`, 'ether'));
}

const ethAmount = process.argv[2];
const main = async function() {
  const myWalletAddress = (await web3.eth.getAccounts())[0]

  console.log('before swapEtherToTokenToCTokenByUniswap');
  await showBalances(myWalletAddress);
  console.log();

  // eth
  const result = await ethToDai.methods.swapEtherToTokenToCTokenByUniswap(uniswap.options.address, dai.options.address, cDai.options.address, Math.floor(Date.now() / 1000) + 300).send({
    from: myWalletAddress, // Some Ganache wallet address
    gasLimit: web3.utils.toHex(500000),        // posted at compound.finance/developers#gas-costs
    gasPrice: web3.utils.toHex(20000000000),   // use ethgasstation.info (mainnet only)
    value: web3.utils.toHex(web3.utils.toWei(`${ethAmount}`, 'ether'))
  })
  console.log('ethToDai.methods.swapEtherToTokenToCTokenByUniswap result', result.status);

  console.log('after swapEtherToTokenToCTokenByUniswap');
  await showBalances(myWalletAddress);
  console.log();

  process.exit(0);
}

main().catch((err) => {
  console.error('[ERROR]', err);
  process.exit(1);
});

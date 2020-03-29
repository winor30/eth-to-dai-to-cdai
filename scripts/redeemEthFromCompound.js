const {
  ethToDai,
  uniswap,
  web3,
  dai,
  cDai
} = require('./setupContract');

const showBalances = async (myWalletAddress) => {
  const cDaiBalanceOfResult = await cDai.methods.balanceOf(ethToDai.options.address).call();
  console.log('cDai balanceOf', cDaiBalanceOfResult);

  const balanceEth = await web3.eth.getBalance(myWalletAddress);
  console.log('eth balance', web3.utils.fromWei(`${balanceEth}`, 'ether'));
}

const main = async function() {
  const myWalletAddress = (await web3.eth.getAccounts())[0]
  console.log('before send')
  await showBalances(myWalletAddress);
  console.log();

  // eth
  const result = await ethToDai.methods.redeemAll(uniswap.options.address, dai.options.address, cDai.options.address, Math.floor(Date.now() / 1000) + 300).send({
    from: myWalletAddress, // Some Ganache wallet address
    gasLimit: web3.utils.toHex(500000),        // posted at compound.finance/developers#gas-costs
    gasPrice: web3.utils.toHex(20000000000),   // use ethgasstation.info (mainnet only)
    value: 0
  })
  console.log('ethToDai.methods.redeemAll result', result.status);

  console.log('after send')
  await showBalances(myWalletAddress);
  console.log();

  process.exit(0);
}

main().catch((err) => {
  console.error('[ERROR]', err);
  process.exit(1);
});

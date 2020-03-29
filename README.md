# eth-to-dai-to-cdai
- **test contract**
- convert eth to cdai when depositing
- convert cdai to eth when redeeming

# command
**.env**
```.env
INFURA_KEY="***"
NETWORK="rinkeby"
MNEMONIC="***"
ETH_TO_DAI="0x***"
```

**deploy**
```sh
$ npm run deploy:rinkeby
```

**deposit**
```sh
$ npm run deposit -- 0.1
```

**redeem**
```sh
$ npm run redeem
```

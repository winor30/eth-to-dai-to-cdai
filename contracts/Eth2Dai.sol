pragma solidity 0.5.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/ownership/Ownable.sol";

/// @title Uniswap exchange interface
interface UniswapExchangeInterface {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    // Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    // ERC20 comaptibility for liquidity tokens
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    // Never use
    function setup(address token_addr) external;
}

/// @title CToekn interface
interface CERC20 {
    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);

    function balanceOf(address owner) external view returns (uint256);
}


contract Eth2Dai is Ownable {
    uint256 constant UINT256_MAX = ~uint256(0);
    constructor ()
      public
      Ownable()
    {}
    event MyLog(string, uint256);
    event ReceivePayable(address);

    function() external payable {
        emit ReceivePayable(address(msg.sender));
    }

    // Eth -> Uniswap -> Token -> CTokenに変換して、デポジット
    function swapEtherToTokenToCTokenByUniswap (address payable uniswapAddress, address tokenAddress, address cTokenAddress, uint256 deadline) public payable {
        // UniswapでETH -> ERC20へ変換
        uint256 tokenAmount = swapEthToToken(uniswapAddress, deadline);
        emit MyLog("token for swap result", tokenAmount);
        // ERC20 -> CTokenの発行
        uint256 cTokenResult = supplyErc20ToCompound(tokenAddress, cTokenAddress, tokenAmount);
        emit MyLog("ctoken for supply result to compound", cTokenResult);
    }

    function swapEthToToken(address payable uniswapAddress, uint256 deadline) public payable returns (uint256) {
        UniswapExchangeInterface _uniswapExchange = UniswapExchangeInterface(uniswapAddress);
        uint256 tokenAmount = _uniswapExchange.ethToTokenSwapInput.value(msg.value)(1, deadline);
        return tokenAmount;
    }

    function supplyErc20ToCompound(
        address _erc20Contract,
        address _cErc20Contract,
        uint256 _numTokensToSupply
    ) public returns (uint256) {
        ERC20 underlying = ERC20(_erc20Contract);
        CERC20 cToken = CERC20(_cErc20Contract);
        underlying.approve(_cErc20Contract, _numTokensToSupply);

        uint256 mintResult = cToken.mint(_numTokensToSupply);
        return mintResult;
    }


    // CTokenを全てETHで引き出す
    function redeemAll (address uniswapAddress, address tokenAddress, address cTokenAddress, uint256 deadline) public onlyOwner {
        // CtokenをERC20へ戻す
        redeemErc20FromCompound(cTokenAddress);
        // ERC20からETHへ戻す
        uint256 ethAmount = swapTokenToEth(uniswapAddress, tokenAddress, deadline);
        emit MyLog("ethAmount for redeem result from uniswap", ethAmount);
        address(msg.sender).send(address(this).balance);
    }

    function redeemErc20FromCompound(address _cErc20Contract) public onlyOwner returns (uint256) {
        CERC20 cToken = CERC20(_cErc20Contract);
        uint256 targetRedeemTargetTokenAmount = cToken.balanceOf(address(this));
        uint256 redeemResult = cToken.redeem(targetRedeemTargetTokenAmount);
        return redeemResult;
    }

    function swapTokenToEth(address uniswapAddress, address _erc20Contract, uint256 deadline) public onlyOwner returns (uint256) {
        ERC20 token = ERC20(_erc20Contract);
        uint256 tokenAmount = token.balanceOf(address(this));
        bool success = token.approve(uniswapAddress, tokenAmount);
        require(success, "failed approve from this to uniswapaddress");

        UniswapExchangeInterface _uniswapExchange = UniswapExchangeInterface(uniswapAddress);
        uint256 ethAmount = _uniswapExchange.tokenToEthSwapInput(tokenAmount, 1, deadline);
        return ethAmount;
    }
}

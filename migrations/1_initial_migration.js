const Eth2Dai = artifacts.require("./Eth2Dai");

module.exports = function(deployer) {
  deployer.deploy(Eth2Dai);
};

const Liquidity = artifacts.require("Liquidity");
const Token = artifacts.require("Token");
const TestToken = artifacts.require("TestToken");

module.exports = function(deployer) {
  const totalSupply = 100000000000000000000;
  deployer.deploy(TestToken, "RewardToken", "RWT", 18, totalSupply.toString(), '0x23eD969565C43586C80a126E68d75237936A902e');
  deployer.deploy(Token, "MineToken", "MNT", 18, totalSupply.toString(), '0x23eD969565C43586C80a126E68d75237936A902e').then(() => {
    return deployer.deploy(Liquidity, "Rookie", Token.address, TestToken.address);
  })
};
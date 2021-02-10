const Rookie_v5 = artifacts.require("Rookie_v5");
const Token = artifacts.require("Token");

module.exports = function(deployer) {
  const totalSupply = 100000000000000000000;
  deployer.deploy(Token, "MineToken", "MNT", 18, totalSupply.toString(), '0x23eD969565C43586C80a126E68d75237936A902e').then(() => {
    return deployer.deploy(Rookie_v5, "Rookie", Token.address, 58, 30);
  })
  //deployer.deploy(RookieFinal, "Rookie", '0x6d070e46edebd9252be4424af3e79c76247ec532');
};
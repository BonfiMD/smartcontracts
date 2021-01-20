const Rookie_v3 = artifacts.require("Rookie_v3");
const Token = artifacts.require("Token");

module.exports = function(deployer, network, accounts) {
  const totalSupply = 100000000000000000000;
  deployer.deploy(Token, "MineToken", "MNT", 18, totalSupply.toString(), accounts[0]).then(() => {
    return deployer.deploy(Rookie_v3, "Rookie", Token.address, 58, 30);
  })
};
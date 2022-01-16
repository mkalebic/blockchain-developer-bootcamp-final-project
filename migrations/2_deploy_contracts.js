var Adventurers = artifacts.require("ForgottenAdventurers");

RINKEBY_VRF_ADDR = "0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B"
RINKEBY_LINK_ADDR = "0x01BE23585060835E02B77ef475b0Cc51aA1e0709"
RINKEBY_KEY_HASH = "0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311"
RINKEBY_FEE = "100000000000000000"

module.exports = function(deployer) {
  deployer.deploy(Adventurers, RINKEBY_VRF_ADDR, RINKEBY_LINK_ADDR, RINKEBY_KEY_HASH, RINKEBY_FEE);
};
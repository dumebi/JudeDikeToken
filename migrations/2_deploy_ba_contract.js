/* eslint-disable no-undef */
const TokenContract = artifacts.require('JudeDikeToken');


module.exports = (deployer) => {
  deployer.deploy(TokenContract, "JDT", "JudeDikeToken", 1000000, {gas: 4700000});
};
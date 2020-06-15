const TokenPool = artifacts.require('TokenPool');

module.exports = function (deployer) {
    deployer.deploy(TokenPool, '0x5830df14d1a864eace60476a4723140ad669b3ab');
};
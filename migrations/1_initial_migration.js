const Decentraskill = artifacts.require('Decentraskill')
// Deploys the smart contract "Decentraskill"
module.exports = function (deployer) {
    deployer.deploy(Decentraskill)
}
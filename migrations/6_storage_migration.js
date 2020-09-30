const Storage = artifacts.require('Storage');
const Portion = artifacts.require('Portion');
const Land = artifacts.require('Land');

module.exports = async function (deployer) {
  await deployer.deploy(Storage);
  await deployer.deploy(Portion, Storage.address);
  await deployer.deploy(Land, Storage.address);
};

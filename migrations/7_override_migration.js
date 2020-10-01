const Storage = artifacts.require('Storage');
const Portion = artifacts.require('Portion');
const Land = artifacts.require('Land');
const Recordable = artifacts.require('Recordable');

module.exports = async function (deployer) {
  await deployer.deploy(Recordable);
  await deployer.deploy(Storage);
  await deployer.deploy(Portion, Storage.address);
  await deployer.deploy(Land, Storage.address);
};

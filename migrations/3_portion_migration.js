const Product = artifacts.require('Product');
const ProductionActivity = artifacts.require('ProductionActivity');
const Maintenance = artifacts.require('Maintenance');
const Storage = artifacts.require('Storage');
const Portion = artifacts.require('Portion');

module.exports = async function (deployer) {
  await deployer.deploy(Maintenance);
  await deployer.deploy(Product);
  await deployer.deploy(ProductionActivity);
  await deployer.deploy(Storage);
  await deployer.deploy(Portion, Storage.address);
};
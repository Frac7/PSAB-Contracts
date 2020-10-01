const Product = artifacts.require('Product');
const ProductionActivity = artifacts.require('ProductionActivity');
const Maintenance = artifacts.require('Maintenance');

module.exports = async function (deployer) {
  await deployer.deploy(Product);
  await deployer.deploy(ProductionActivity);
  await deployer.deploy(Maintenance);
};

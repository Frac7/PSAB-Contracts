const Product = artifacts.require('Product');
const ProductionActivity = artifacts.require('ProductionActivity');
const Certifiable = artifacts.require('Certifiable');

module.exports = async function (deployer) {
  await deployer.deploy(Product);
  await deployer.deploy(ProductionActivity);
  await deployer.deploy(Certifiable);
};

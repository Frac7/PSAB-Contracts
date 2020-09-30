const Product = artifacts.require('Product');
const ProductionActivity = artifacts.require('ProductionActivity');

module.exports = async function (deployer) {
    await deployer.deploy(Product);
    await deployer.deploy(ProductionActivity);
};
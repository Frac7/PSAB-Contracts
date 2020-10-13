const Recordable = artifacts.require("Recordable");
const Certifiable = artifacts.require("Certifiable");
const Maintenance = artifacts.require("Maintenance");
const Product = artifacts.require("Product");
const ProductionActivity = artifacts.require("ProductionActivity");
const Storage = artifacts.require("Storage");
const Portion = artifacts.require("Portion");
const Land = artifacts.require("Land");

module.exports = async function (deployer) {
  await deployer.deploy(Recordable);
  await deployer.deploy(Certifiable);
  await deployer.deploy(Maintenance);
  await deployer.deploy(Product);
  await deployer.deploy(ProductionActivity);
  await deployer.deploy(Storage);
  await deployer.deploy(Portion, Storage.address);
  await deployer.deploy(Land, Storage.address);
};

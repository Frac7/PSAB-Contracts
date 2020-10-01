const Recordable = artifacts.require("Recordable");
const Certifiable = artifacts.require("Certifiable");
const Maintenance = artifacts.require("Maintenance");
const Product = artifacts.require("Product");
const ProductionActivity = artifacts.require("ProductionActivity");
const Storage = artifacts.require("Storage");
const Portion = artifacts.require("Portion");
const Land = artifacts.require("Land");

module.exports = function (deployer) {
  deployer.deploy(Recordable);
  deployer.deploy(Certifiable);
  deployer.deploy(Maintenance);
  deployer.deploy(Product);
  deployer.deploy(ProductionActivity);
  deployer.deploy(Storage);
  deployer.deploy(Portion, Storage.address);
  deployer.deploy(Land, Storage.address);
};

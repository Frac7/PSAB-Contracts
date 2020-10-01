const truffleAssert = require('truffle-assertions');
const Product = artifacts.require('Product');
const ProductionActivity = artifacts.require('ProductionActivity');
const Maintenance = artifacts.require('Maintenance');

contract('Recordable test', async (accounts) => {
    it('Should register a product', async () => {
        const instance = await Product.deployed();

        await instance.register('Product 0', 0, { from: accounts[1] });
        await truffleAssert.passes(
            instance.getById(0, { from: accounts[1] }),
            'Product must be registered'
        );
        const total = await instance.getTotal({ from: accounts[1] });
        assert.equal(1, total, 'There must be exactly 1 product registered');

        const productsByOperator = await instance.getByOperator(accounts[1], { from: accounts[1] });
        expect(productsByOperator[0].toNumber()).to.be.equal(0);

        const productsByPortion = await instance.getByPortion(0, { from: accounts[1] });
        expect(productsByPortion[0].toNumber()).to.be.equal(0);
    });

    it('Should register a production activity', async () => {
        const instance = await ProductionActivity.deployed();

        await instance.register('Production 0', 0, { from: accounts[1] });
        await truffleAssert.passes(
            instance.getById(0, { from: accounts[1] }),
            'Production activity must be registered'
        );
        const total = await instance.getTotal({ from: accounts[1] });
        assert.equal(1, total, 'There must be exactly 1 production activity registered');

        const productionsByOperator = await instance.getByOperator(accounts[1], { from: accounts[1] });
        expect(productionsByOperator[0].toNumber()).to.be.equal(0);

        const productionsByPortion = await instance.getByPortion(0, { from: accounts[1] });
        expect(productionsByPortion[0].toNumber()).to.be.equal(0);
    });

    it('Should register a maintenance activity', async () => {
        const instance = await Maintenance.deployed();

        await instance.register('Maintenance 0', 0, { from: accounts[1] });
        await truffleAssert.passes(
            instance.getById(0, { from: accounts[1] }),
            'Maintenance activity must be registered'
        );
        const total = await instance.getTotal({ from: accounts[1] });
        assert.equal(1, total, 'There must be exactly 1 maintenance activity registered');

        const maintenancesByOperator = await instance.getByOperator(accounts[1], { from: accounts[1] });
        expect(maintenancesByOperator[0].toNumber()).to.be.equal(0);

        const maintenancesByPortion = await instance.getByPortion(0, { from: accounts[1] });
        expect(maintenancesByPortion[0].toNumber()).to.be.equal(0);
    });
});
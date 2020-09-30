const truffleAssert = require('truffle-assertions');
const Product = artifacts.require('Product');
const ProductionActivity = artifacts.require('ProductionActivity');
const Maintenance = artifacts.require('Maintenance');

contract('Recordable test', async (accounts) => {
    it('should register a product', async () => {
        const instance = await Product.deployed();

        await instance.register('Product 0', 0, { from: accounts[1] });
        await truffleAssert.passes(
            instance.getById(0, { from: accounts[1] }),
            'Product must be registered'
        );
        const total = await instance.getTotal({ from: accounts[1] });
        assert.equal(1, total, 'There must be exactly 1 product registered');

        //const productsByOperator = await instance.getByOperator(accounts[1], { from: accounts[1] }); // TODO: fix
        //expect(productsByOperator.includes(0), 'Product must be registered by this operator').to.be.true;

        //const productsByPortion = await instance.getByPortion(0, { from: accounts[1] }); // TODO: fix
        //expect(productsByPortion.includes(0), 'Product must be registered in this portion').to.be.true;
    });

    it('should register a production activity', async () => {
        const instance = await ProductionActivity.deployed();

        await instance.register('Production 0', 0, { from: accounts[1] });
        await truffleAssert.passes(
            instance.getById(0, { from: accounts[1] }),
            'Production activity must be registered'
        );
        const total = await instance.getTotal({ from: accounts[1] });
        assert.equal(1, total, 'There must be exactly 1 production activity registered');

        //const productionsByOperator = await instance.getByOperator(accounts[1], { from: accounts[1] }); // TODO: fix
        //expect(productionsByOperator.includes(0), 'Production activity must be registered by this operator').to.be.true;

        //const productionsByPortion = await instance.getByPortion(0, { from: accounts[1] }); // TODO: fix
        //expect(productionsByPortion.includes(0), 'Production activity must be registered in this portion').to.be.true;
    });

    it('should register a maintenance activity', async () => {
        const instance = await Maintenance.deployed();

        await instance.register('Maintenance 0', 0, { from: accounts[1] });
        await truffleAssert.passes(
            instance.getById(0, { from: accounts[1] }),
            'Maintenance activity must be registered'
        );
        const total = await instance.getTotal({ from: accounts[1] });
        assert.equal(1, total, 'There must be exactly 1 maintenance activity registered');

        //const maintenancesByOperator = await instance.getByOperator(accounts[1], { from: accounts[1] }); // TODO: fix
        //expect(maintenancesByOperator.includes(0), 'Maintenance activity must be registered by this operator').to.be.true;

        //const maintenancesByPortion = await instance.getByPortion(0, { from: accounts[1] }); // TODO: fix
        //expect(maintenancesByPortion.includes(0), 'Maintenance activity must be registered in this portion').to.be.true;
    });
});
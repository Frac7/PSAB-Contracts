const truffleAssert = require('truffle-assertions');
const Portion = artifacts.require('Portion');
const Product = artifacts.require('Product');
const ProductionActivity = artifacts.require('ProductionActivity');
const Maintenance = artifacts.require('Maintenance');

contract('Portion test', async (accounts) => {
    it('Should register a portion', async () => {
        const instance = await Portion.deployed();

        await instance.register(0, 'Portion 0', accounts[1]);
        await truffleAssert.passes(
            instance.getById(0, { from: accounts[1] }),
            'Portion must be registered'
        );
        const total = await instance.getTotal({ from: accounts[1] });
        assert.equal(2, total, 'There must be exactly 2 portions registered');

        const idByOwner = await instance.getByOwner(accounts[1], { from: accounts[1] });
        assert.equal(0, idByOwner[0].toNumber(), 'Owner has only the portion with ID = 0 and ID = 1');
        assert.equal(1, idByOwner[1].toNumber(), 'Owner has only the portion with ID = 0 and ID = 1');

        await truffleAssert.fails(
            instance.register(0, 'Portion 1', accounts[1], { from: accounts[1] }),
            'Portion cannot be created'
        );
    });

    it('Should register documents', async () => {
        const instance = await Portion.deployed();

        await truffleAssert.passes(
            instance.registerDocument(0, '0x4174746163686d656e74', '0x258b32d46b8847cf6b10cd1848aecd9b7295df31f095cdba015075e0e33beade', { from: accounts[1] }),
            'Owner must be able to register documents for his portion'
        );
        await truffleAssert.fails(
            instance.registerDocument(0, '0x4174746163686d656e74', '0x258b32d46b8847cf6b10cd1848aecd9b7295df31f095cdba015075e0e33beade', { from: accounts[0] }),
            'Only owner is allowed'
        );

        const portion = await instance.getById(0, { from: accounts[1] });
        assert.equal(portion[0].documents.length, 1, 'There is only one document for this portion');
    });

    it('Should define terms', async () => {
        const instance = await Portion.deployed();

        await instance.register(1, 'Portion 2', accounts[1]);
        await truffleAssert.passes(
            instance.defineTerms(2, 42, 1604102400, 'Expected production', 'Periodicity', 42, 42, accounts[2], { from: accounts[1] }),
            'Owner must be able to define the contract terms for his portion'
        );
        await truffleAssert.fails(
            instance.defineTerms(2, 42, 1604102400, 'Expected production', 'Periodicity', 42, 42, accounts[2], { from: accounts[0] }),
            'Only owner is allowed'
        );
    });

    it('Should sell his portion', async () => {
        const instance = await Portion.deployed();

        await instance.register(2, 'Portion 4', accounts[1]);
        await instance.defineTerms(4, 42, 1604102400, 'Expected production', 'Periodicity', 42, 42, accounts[2], { from: accounts[1] });

        await truffleAssert.passes(
            instance.sell(4, accounts[2], accounts[1], { from: accounts[1] }),
            'Owner must be able to sell his portion'
        );
        await truffleAssert.passes(
            instance.sell(4, accounts[3], accounts[2], { from: accounts[2] }),
            'Buyer must be able to sell this portion'
        );
        await truffleAssert.fails(
            instance.sell(4, accounts[2], accounts[0], { from: accounts[0] }),
            'Only owner or buyer are allowed'
        );

        const portions = await instance.getByBuyer(accounts[3], { from: accounts[1] });
        expect(portions[0].toNumber()).to.be.equal(4);

        const buyers = await instance.getBuyersByPortion(4, { from: accounts[1] });
        expect(buyers[2]).to.be.equal(accounts[3]);
    });

    it('Should return all the portions for the given land', async () => {
        const instance = await Portion.deployed();

        const portions = await instance.getByLand(0, { from: accounts[1] });
        expect(portions.length).to.be.equal(2);
        expect(portions[0].toNumber()).to.be.equal(0);
        expect(portions[1].toNumber()).to.be.equal(1);
        expect(portions[2]).to.be.equal(undefined);
    });

    it('Should register a product', async () => {
        const instance = await Portion.deployed();
        const product = await Product.deployed();

        await truffleAssert.passes(
            instance.registerProduct('Product 0', 0, product.address, { from: accounts[3] }),
            'Operator must be able to register a product'
        );
        await truffleAssert.reverts(
            instance.registerProduct('Product 1', 42, product.address, { from: accounts[3] }),
            'Element does not exist'
        );
    });

    it('Should register a production activity', async () => {
        const instance = await Portion.deployed();
        const production = await ProductionActivity.deployed();

        await truffleAssert.passes(
            instance.registerProductionActivity('Production 0', 0, production.address, { from: accounts[3] }),
            'Operator must be able to register a production activity'
        );
        await truffleAssert.reverts(
            instance.registerProductionActivity('Production 1', 42, production.address, { from: accounts[3] }),
            'Element does not exist'
        );
    });

    it('Should register a maintenance activity', async () => {
        const instance = await Portion.deployed();
        const maintenance = await Maintenance.deployed();

        await truffleAssert.passes(
            instance.registerMaintenance('Production 0', 0, maintenance.address, { from: accounts[3] }),
            'Operator must be able to register a production activity'
        );
        await truffleAssert.reverts(
            instance.registerMaintenance('Production 1', 42, maintenance.address, { from: accounts[3] }),
            'Element does not exist'
        );
    });

    it('Should remove buyer when ownership expires', async () => {
        const instance = await Portion.deployed();

        await instance.register(3, 'Portion 6', accounts[1]);
        await instance.defineTerms(6, 42, 1604102400, 'Expected production', 'Periodicity', 42, 42, accounts[2], { from: accounts[1] });
        await instance.sell(6, accounts[2], accounts[1], { from: accounts[1] });

        const buyersByPortions = await instance.getBuyersByPortion(6);
        expect(buyersByPortions.includes(accounts[2])).to.be.true;
        
        await instance.defineTerms(6, 42, 1, 'Expected production', 'Periodicity', 42, 42, accounts[2], { from: accounts[1] });

        await truffleAssert.passes(
            instance.ownershipExpiration(6),
            'Ownership must be expired'
        );

        const portionData = await instance.getById(6, { from: accounts[1] });
        expect(portionData[1].buyer).to.be.equal('0x0000000000000000000000000000000000000000');
    });

    it('Should not remove buyer when duration is perpetual', async () => {
        const instance = await Portion.deployed();

        await instance.register(4, 'Portion 8', accounts[1]);
        await instance.defineTerms(8, 42, 1604102400, 'Expected production', 'Periodicity', 42, 42, accounts[2], { from: accounts[1] });
        await instance.sell(8, accounts[2], accounts[1], { from: accounts[1] });

        const buyersByPortions = await instance.getBuyersByPortion(8);
        expect(buyersByPortions.includes(accounts[2])).to.be.true;
        
        await instance.defineTerms(8, 42, 0, 'Expected production', 'Periodicity', 42, 42, accounts[2], { from: accounts[1] });

        await truffleAssert.reverts(
            instance.ownershipExpiration(8),
            'Owneship expiration not allowed'
        );

        const portionData = await instance.getById(8, { from: accounts[1] });
        expect(portionData[1].buyer).to.be.equal(accounts[2]);
    });

    it('Should not remove buyer when element does not exist', async () => {
        const instance = await Portion.deployed();

        await truffleAssert.reverts(
            instance.ownershipExpiration(10),
            'Element does not exist'
        );
    });

    it('Should not remove buyer when buyer is not set', async () => {
        const instance = await Portion.deployed();

        await instance.register(5, 'Portion 10', accounts[1]);

        await truffleAssert.reverts(
            instance.ownershipExpiration(10),
            'Buyer is not set'
        );
    });
});
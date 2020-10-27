const truffleAssert = require('truffle-assertions');
const Land = artifacts.require('Land');
const Portion = artifacts.require('Portion');

contract('Land test', async (accounts) => {
    it('Should register a land', async () => {
        const instance = await Land.deployed();

        await instance.register('Land 0', { from: accounts[1] });
        await truffleAssert.passes(
            instance.getById(0, { from: accounts[1] }),
            'Land must be registered'
        );
        const total = await instance.getTotal({ from: accounts[1] });
        assert.equal(1, total, 'There must be exactly 1 land registered');

        const idByOwner = await instance.getByOwner(accounts[1], { from: accounts[1] });
        assert.equal(0, idByOwner, 'Owner has only the land with ID = 0');

        const ownerById = await instance.getOwnerByLand(0, { from: accounts[1] });
        assert.equal(accounts[1], ownerById, 'The land with ID = 0 is owned by account1');
    });

    it('Should register documents', async () => {
        const instance = await Land.deployed();

        await truffleAssert.passes(
            instance.registerDocument(0, '0x4174746163686d656e74', '0x258b32d46b8847cf6b10cd1848aecd9b7295df31f095cdba015075e0e33beade', { from: accounts[1] }),
            'Owner must be able to register documents for his land'
        );
        await truffleAssert.fails(
            instance.registerDocument(0, '0x4174746163686d656e74', '0x258b32d46b8847cf6b10cd1848aecd9b7295df31f095cdba015075e0e33beade', { from: accounts[0] }),
            'Only owner is allowed'
        );

        const land = await instance.getById(0, { from: accounts[1] });
        assert.equal(land.documents.length, 1, 'There is only one document for this land');
    });

    it('Should divide land', async () => {
        const instance = await Land.deployed();
        const portion = await Portion.deployed();

        await instance.register('Land 1', { from: accounts[1] });
        await truffleAssert.passes(
            instance.divide(1, 'Portion 0', portion.address, { from: accounts[1] }),
            'Owner must be able to divide his land in portions'
        );
        await truffleAssert.fails(
            instance.divide(1, 'Portion 0', portion.address, { from: accounts[0] }),
            'Only owner is allowed'
        );
        await truffleAssert.fails(
            instance.divide(1, 'Portion 2', portion.address, { from: accounts[1] }),
            'Land cannot be divided further'
        );
    });
});
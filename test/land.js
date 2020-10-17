const truffleAssert = require('truffle-assertions');
const Land = artifacts.require('Land');
const Portion = artifacts.require('Portion');

contract('Land test', async (accounts) => {
    it('Should register a land', async () => {
        const instance = await Land.deployed();

        await instance.register('Land 0', 'Attachment encoding', { from: accounts[1] });
        await truffleAssert.passes(
            instance.getById(0, { from: accounts[1] }),
            'Land must be registered'
        );
        const total = await instance.getTotal({ from: accounts[1] });
        assert.equal(1, total, 'There must be exactly 1 land registered');

        const idByOwner = await instance.getByOwner(accounts[1], { from: accounts[1] });
        assert.equal(1, idByOwner.length, 'Owner has exactly one land');
        assert.equal(0, idByOwner[0], 'Owner has only the land with ID = 0');

        const ownerById = await instance.getOwnerByLand(0, { from: accounts[1] });
        assert.equal(accounts[1], ownerById, 'The land with ID = 0 is owned by account1');
    });

    it('Should divide land', async () => {
        const instance = await Land.deployed();
        const portion = await Portion.deployed();

        await instance.register('Land 1', 'Attachment encoding', { from: accounts[1] });
        await truffleAssert.passes(
            instance.divide(1, 'Portion 0', 'Attachment encoding', portion.address, { from: accounts[1] }),
            'Owner must be able to divide his land in portions'
        );
        await truffleAssert.fails(
            instance.divide(1, 'Portion 0', 'Attachment encoding', portion.address, { from: accounts[0] }),
            'Only owner is allowed'
        );
    });
});
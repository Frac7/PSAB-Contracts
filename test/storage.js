const truffleAssert = require('truffle-assertions');
const Storage = artifacts.require('Storage');
const Portion = artifacts.require('Portion');
const Land = artifacts.require('Land');

contract('Storage test', async (accounts) => {
    it('Should store data', async () => {
        const instance = await Storage.deployed();

        await instance.add('Data 0', { from: accounts[1] });
        
        const hash = await instance.getById(0, { from: accounts[1] });
        expect(hash).not.to.be.equal(0);
    });

    it('Should store land documents', async () => {
        const instance = await Land.deployed();
        const storage = await Storage.deployed();

        await instance.register('Land 0', { from: accounts[1] });
        await instance.registerDocument(0, '0x4174746163686d656e74', 'Attachment encoding', { from: accounts[1] });

        const hash = await storage.getById(1, { from: accounts[1] });
        expect(hash).not.to.be.equal(0);
    });

    it('Should store portion documents', async () => {
        const instance = await Portion.deployed();
        const storage = await Storage.deployed();

        await instance.register(0, 'Portion 0', accounts[1], { from: accounts[1] });
        await instance.registerDocument(0, '0x4174746163686d656e74', 'Attachment encoding', { from: accounts[1] });

        const hash = await storage.getById(2, { from: accounts[1] });
        expect(hash).not.to.be.equal(0);
    });
});
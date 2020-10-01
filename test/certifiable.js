const truffleAssert = require('truffle-assertions');
const Product = artifacts.require('Product');
const ProductionActivity = artifacts.require('ProductionActivity');

contract('Certifiable test', async (accounts) => {
    it('Should certify a product', async () => {
        const instance = await Product.deployed();

        await instance.register('Product 0', 0, accounts[1], { from: accounts[1] });
        await truffleAssert.passes(
            instance.certifyProduct(0, 'Certification 0', { from: accounts[1] }),
            'Product must be certified'
        );
        await truffleAssert.reverts(
            instance.certifyProduct(1, 'Certification 0', { from: accounts[1] }),
            'Element does not exist'
        );
    });

    it('Should certify a production activity', async () => {
        const instance = await ProductionActivity.deployed();

        await instance.register('Product 0', 0, accounts[1], { from: accounts[1] });
        await truffleAssert.passes(
            instance.certifyProduction(0, 'Certification 0', { from: accounts[1] }),
            'Production must be certified'
        );
        await truffleAssert.reverts(
            instance.certifyProduction(1, 'Certification 0', { from: accounts[1] }),
            'Element does not exist'
        );
    });
});
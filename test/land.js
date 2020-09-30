const Land = artifacts.require('Land');

let land;

before(async () => {
    land = await Land.new();
});

contract('Land tests', (account) => {
    
});
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol';
import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';
import './Storage.sol';
import './Portion.sol';

/**
 * This contract represents a land/agricultural resource.
 */
contract Land is ERC721 {
    using SafeMath for uint256;
    
    //owner data
    struct Owner {
        uint256[] landsOwned; //ids of owner's lands
    }
    
    //state variables of this contract
    mapping (address => Owner) private owners;
    //given the owner's address as the key, the value is the strcut of type owner
    //in this way, given an address, the list of his/her lands can be retrieve
    uint private lastLandId;
    mapping (uint256 => address) private ownersByLandId;
    Storage private dataStorage;
    
    //the constructor is called once before the deploy to the blockchain
    //the Storage contract must be on the blockchain before the deploy of this contract
    constructor (string memory name, string memory symbol, address _dataStorage) public ERC721 (name, symbol) {
        dataStorage = Storage(_dataStorage);
    }
    
    //only owner address associated to the land id
    modifier onlyOwner(uint256 _landId) {
        require(ownersByLandId[_landId] == msg.sender);
        _;
    }
    
    function register(bytes32 _data) external {
        owners[msg.sender].landsOwned.push(lastLandId + 1);
        dataStorage.add(_data);
        lastLandId++;
    }
    
    function divide(uint256 _landId, bytes32 _data) external onlyOwner(_landId) {
        Portion portion = new Portion('Portion', 'Portion', address(dataStorage));
        portion.register(_landId, _data);
    }
}

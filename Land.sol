// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol';
import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';
import './Storage.sol';
import './Portion.sol';

/**
 * This contract represents a land/agricultural resource.
 */
contract Land is ERC721 {
    using SafeMath for uint256;
    
    //land data
    struct Data {
        string description;
        bytes32[] documents;
    }
    
    //owner data
    struct Owner {
        uint256[] landsOwned; //ids of owner's lands
    }
    
    //state variables of this contract
    mapping (uint256 => Data) private lands;
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
    
    function register(string calldata _description, bytes32[] calldata _documents, bytes32 _data) external {
        owners[msg.sender].landsOwned.push(lastLandId);
        
        lands[lastLandId].description = _description;
        lands[lastLandId].documents = _documents;
        
        dataStorage.add(_data);
        
        lastLandId++;
    }
    
    function divide(uint256 _id, string calldata _description, bytes32 _data, address contractAddress) external onlyOwner(_id) {
        Portion(contractAddress).register(_id, _description, _data);
    }
    
    function getById(uint256 _id) external view returns (Data memory) {
        return lands[_id];
    }
    
    function getByOwner(address _address) external view returns (Owner memory) {
        return owners[_address];
    }
    
    function getOwnerByLand(uint256 _id) external view returns (address) {
        return ownersByLandId[_id];
    }
    
    function getTotalLands() external view returns (uint256) {
        return lastLandId;
    }
}

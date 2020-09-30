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
        string documents;
        uint256 hashId;
        bool hasValue;
    }
    
    //state variables of this contract
    mapping (uint256 => Data) private lands;
    mapping (address => uint256[]) private landsByOwner;
    //given the owner's address as the key, the value is the strcut of type owner
    //in this way, given an address, the list of his/her lands can be retrieved
    uint256 private lastLandId;
    mapping (uint256 => address) private ownersByLandId;
    Storage private dataStorage;
    
    //the constructor is called once before the deploy to the blockchain
    //the Storage contract must be on the blockchain before the deploy of this contract
    constructor (string memory name, string memory symbol, address _dataStorage) public ERC721 (name, symbol) {
        dataStorage = Storage(_dataStorage);
    }
    
    //only owner address associated to the land id
    modifier onlyOwner(uint256 _landId) {
        require(ownersByLandId[_landId] == msg.sender, 'Only owner is allowed');
        _;
    }
    
    function register(string calldata _description, string calldata _documents, string calldata _base64) external {
        landsByOwner[msg.sender].push(lastLandId);
        
        lands[lastLandId].description = _description;
        lands[lastLandId].documents = _documents;
        lands[lastLandId].hashId = dataStorage.add(_base64);
        lands[lastLandId].hasValue = true;
        
        lastLandId++;
    }
    
    function divide(uint256 _id, string calldata _description, string calldata _documents, string calldata _base64, address contractAddress) external onlyOwner(_id) {
        if (!lands[_id].hasValue) revert('Element does not exist');
        Portion(contractAddress).register(_id, _description, _documents, _base64);
    }
    
    function getById(uint256 _id) external view returns (Data memory) {
        if (!lands[_id].hasValue) revert('Element does not exist');
        return lands[_id];
    }
    
    function getByOwner(address _address) external view returns (uint256[] memory) {
        return landsByOwner[_address];
    }
    
    function getOwnerByLand(uint256 _id) external view returns (address) {
        if (!lands[_id].hasValue) revert('Element does not exist');
        return ownersByLandId[_id];
    }
    
    function getTotal() external view returns (uint256) {
        return lastLandId;
    }
}

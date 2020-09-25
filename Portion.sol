// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol';
import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

import './Storage.sol';

contract Portion is ERC721 {
    using SafeMath for uint256;
    
    struct Data {
        string description;
        bytes32[] documents;
    }
    
    struct Owner {
        uint256[] portionsOwned;
    }
    
    struct Buyer {
        uint256[] portionsBought;
    }
    
    struct TermsOfSale {
        uint256 price;
        uint256 duration; //perpetual or for n years
        string expectedProduction;
        string periodicity;
        uint256 expectedMaintenanceCost;
        uint256 expectedProdActivityCost;
        uint256 landId;
        address owner;
        address buyer; //this will be filled after the trading
    }
    
    mapping (uint256 => Data) private portions;
    mapping (address => Owner) private owners;
    mapping (address => Buyer) private buyers;
    mapping (uint256 => TermsOfSale) private portionTerms;
    
    uint256 private lastPortionId;
    
    Storage private dataStorage;
    
    constructor (string memory name, string memory symbol, address _dataStorage) public ERC721 (name, symbol) {
        dataStorage = Storage(_dataStorage);
    }
    
    modifier onlyOwner(uint256 _portionId) {
        require(portionTerms[_portionId].owner == msg.sender);
        _;
    }
    
    modifier onlyOwnerAndBuyer(uint256 _portionId) {
        require(portionTerms[_portionId].owner == msg.sender || portionTerms[_portionId].buyer == msg.sender);
        _;
    }
    
    function register(uint256 _landId, string calldata _description, bytes32[] calldata _documents, bytes32 _data) external {
        portions[lastPortionId].description = _description;
        portions[lastPortionId].documents = _documents;
        
        TermsOfSale memory terms;
        terms.landId = _landId;
        terms.owner = msg.sender;
        
        portionTerms[lastPortionId] = terms;
        
        dataStorage.add(_data);
        
        lastPortionId++;
    }
    
    function defineTerms(
        uint256 _portionId,
        uint256 _price,
        uint256 _duration,
        string calldata _expectedProduction,
        string calldata _periodicity,
        uint256 _expectedMaintenanceCost,
        uint256 _expectedProdActivityCost
    ) external onlyOwner(_portionId) {
        TermsOfSale memory terms;
        terms.price = _price;
        terms.duration = _duration;
        terms.expectedProduction = _expectedProduction;
        terms.periodicity = _periodicity;
        terms.expectedMaintenanceCost = _expectedMaintenanceCost;
        terms.expectedProdActivityCost = _expectedProdActivityCost;

        portionTerms[_portionId] = terms;
    }
    
    function sell(uint256 _portionId, address _buyer) external onlyOwnerAndBuyer(_portionId) { //sell and transfer ownership
        portionTerms[_portionId].buyer = _buyer;
    }
    
    function get(uint256 _id) external view returns (Data memory, TermsOfSale memory) {
        return (portions[_id], portionTerms[_id]);
    }
    
    function getByOwner(address _owner) external view returns (Owner memory) {
        return owners[_owner];
    }
    
    function getByBuyer(address _buyer) external view returns (Buyer memory) {
        return buyers[_buyer];
    }
    
    function getTotalPortions() external view returns (uint256) {
        return lastPortionId;
    }
    
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

import './Storage.sol';

contract Portion is ERC721 {
    using SafeMath for uint256;
    
    struct Owner {
        uint256[] portionsOwned;
    }
    
    struct Buyer {
        uint256[] portionsBought;
    }
    
    struct TermsOfSale {
        uint256 price; //TODO: float
        uint256 duration; //perpetual or for n years
        string expectedProduction;
        string periodicity; //TODO: improve this field
        uint256 expectedMaintenanceCost; //TODO: float
        uint256 expectedProdActivityCost; //TODO: float
        uint256 landId;
        address owner;
        address buyer; //this will be filled after the trading
    }
    
    mapping (address => Owner) private owners;
    mapping (address => Buyer) private buyers;
    mapping (uint256 => TermsOfSale) private portions;
    
    uint256 private lastPortionId;
    
    Storage private dataStorage;
    
    constructor (address _dataStorage) public {
        dataStorage = Storage(_dataStorage);
    }
    
    modifier onlyOwner(uint256 _portionId) {
        require(portions[_portionId].owner == msg.sender);
        _;
    }
    
    modifier onlyOwnerAndBuyer(uint256 _portionId) {
        require(portions[_portionId].owner == msg.sender || portions[_portionId].buyer == msg.sender);
        _;
    }
    
    function register(uint256 _landId, bytes32[] calldata _data) external {
        
        //TODO: test these lines
        TermsOfSale memory terms;
        terms.landId = _landId;
        terms.owner = msg.sender;
        
        portions[lastPortionId + 1] = terms;
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

        portions[_portionId] = terms;
    }
    
    function sell(uint256 _portionId, address _buyer) external onlyOwnerAndBuyer(_portionId) { //sell and transfer ownership
        portions[_portionId].buyer = _buyer; //TODO: improve
    }
    
    //TODO: which information need to be saved?
    function browseHistory(uint256 _portionId) external {
        
    }
    
    //TODO: ownership expiration?
    function ownershipExpiration(uint256 _portionId) external {
        
    }
    
}
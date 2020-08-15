// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

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
        require(ortions[_portionId].owner == msg.sender || portions[_portionId].buyer == msg.sender);
        _;
    }
    
    function register(uint256 _landId, bytes32[] data) {
        
        //TODO: test these lines
        TermsOfSale memory terms;
        terms.landId = _landId;
        terms.owner = msg.sender;
        
        portions[lastPortionId + 1] = terms;
        dataStorage.add(data);
        lastPortionId++;
    }
    
    function defineTerms(
        uint256 _portionId,
        uint256 _price,
        uint256 _duration,
        string _expectedProduction,
        string _periodicity,
        uint256 _expectedMaintenanceCost,
        uint256 _expectedProdActivityCost
    ) external onlyOwner {
        portions[_portionId] = TermsOfSale({ 
            price: _price, 
            duration: _duration, 
            expectedProduction: _expectedProduction,
            periodicity: _periodicity,
            expectedMaintenanceCost: _expectedMaintenanceCost,
            expectedProdActivityCost: _expectedProdActivityCost
        });
    }
    
    function sell(uint256 _portionId, address buyer) external onlyOwnerAndBuyer { //sell and transfer ownership
        try portions[_portionId].buyer = buyer {}
        catch Error(string memory error) {
            return error;
        }
    }
    
    //TODO: which information need to be saved?
    function browseHistory(uint256 _portionId) external {
        
    }
    
    //TODO: ownership expiration?
    function ownershipExpiration(uint256 _portionId) external {
        
    }
    
}
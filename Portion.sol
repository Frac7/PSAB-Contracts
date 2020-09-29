// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol';
import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

import './Storage.sol';
import './Product.sol';
import './Maintenance.sol';
import './ProductionActivity.sol';

contract Portion is ERC721 {
    using SafeMath for uint256;
    
    struct Data {
        uint256 land;
        string description;
        string documents;
        uint256 hashId;
        bool hasValue;
    }
    
    struct TermsOfSale {
        uint256 price;
        string duration; //perpetual or for n years
        string expectedProduction;
        string periodicity;
        uint256 expectedMaintenanceCost;
        uint256 expectedProdActivityCost;
        uint256 landId;
        address owner;
        address buyer; //this will be filled after the trading
    }
    
    mapping (uint256 => Data) private portions;
    mapping (address => uint256[]) private portionsByOwner;
    mapping (address => uint256[]) private portionsByBuyer;
    mapping (uint256 => TermsOfSale) private portionTerms;
    mapping (uint256 => address[]) buyersByPortions;
    
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
    
    function register(uint256 _landId, string calldata _description, string calldata _documents, string calldata _base64) external {
        portions[lastPortionId].description = _description;
        portions[lastPortionId].documents = _documents;
        portions[lastPortionId].land = _landId;
        
        TermsOfSale memory terms;
        terms.landId = _landId;
        terms.owner = msg.sender;
        
        portionTerms[lastPortionId] = terms;
        
        buyersByPortions[lastPortionId].push(msg.sender);
        
        portions[lastPortionId].hashId = dataStorage.add(_base64);
        portions[lastPortionId].hasValue = true;
        
        portionsByOwner[msg.sender].push(lastPortionId);
        
        lastPortionId++;
    }
    
    function defineTerms(
        uint256 _portionId,
        uint256 _price,
        string calldata _duration,
        string calldata _expectedProduction,
        string calldata _periodicity,
        uint256 _expectedMaintenanceCost,
        uint256 _expectedProdActivityCost
    ) external onlyOwner(_portionId) {
        if (!portions[_portionId].hasValue) revert('Element does not exist');
        TermsOfSale memory terms;
        terms.price = _price;
        terms.duration = _duration;
        terms.expectedProduction = _expectedProduction;
        terms.periodicity = _periodicity;
        terms.expectedMaintenanceCost = _expectedMaintenanceCost;
        terms.expectedProdActivityCost = _expectedProdActivityCost;

        portionTerms[_portionId] = terms;
    }
    
    function sell(uint256 _id, address _buyer) external onlyOwnerAndBuyer(_id) { //sell and transfer ownership
        if (!portions[_id].hasValue) revert('Element does not exist');
        portionTerms[_id].buyer = _buyer;
        portionsByBuyer[_buyer].push(_id);
        
        buyersByPortions[_id].push(_buyer);
    }
    
    function getById(uint256 _id) external view returns (Data memory, TermsOfSale memory) {
        if (!portions[_id].hasValue) revert('Element does not exist');
        return (portions[_id], portionTerms[_id]);
    }
    
    function getByOwner(address _owner) external view returns (uint256[] memory) {
        return portionsByOwner[_owner];
    }
    
    function getByBuyer(address _buyer) external view returns (uint256[] memory) {
        return portionsByBuyer[_buyer];
    }
    
    function getBuyersByPortion(uint256 _id) external view returns (address[] memory) {
        return buyersByPortions[_id];
    }
    
    function getTotal() external view returns (uint256) {
        return lastPortionId;
    }
    
    function registerProduct(string calldata _description, uint256 _id, address contractAddress) external {
        if (!portions[_id].hasValue) revert('Element does not exist');
        Product(contractAddress).register(_description, _id);
    }
    
    function registerProductionActivity(string calldata _description, uint256 _id, address contractAddress) external {
        if (!portions[_id].hasValue) revert('Element does not exist');
        ProductionActivity(contractAddress).register(_description, _id);
    }
    
    function registerMaintenance(string calldata _description, uint256 _id, address contractAddress) external {
        if (!portions[_id].hasValue) revert('Element does not exist');
        Maintenance(contractAddress).register(_description, _id);
    }
    
}

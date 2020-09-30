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
        uint256 duration; //perpetual or for n years
        string expectedProduction;
        string periodicity;
        uint256 expectedMaintenanceCost;
        uint256 expectedProdActivityCost;
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
        require(portionTerms[_portionId].owner == msg.sender, 'Only owner is allowed');
        _;
    }
    
    modifier onlyOwnerAndBuyer(uint256 _portionId) {
        require(portionTerms[_portionId].owner == msg.sender || portionTerms[_portionId].buyer == msg.sender, 'Only owner or buyer are allowed');
        _;
    }
    
    function register(uint256 _landId, string calldata _description, string calldata _documents, string calldata _base64) external {
        portions[lastPortionId].description = _description;
        portions[lastPortionId].documents = _documents;
        portions[lastPortionId].land = _landId;
        
        portionTerms[lastPortionId].owner = msg.sender;
        
        buyersByPortions[lastPortionId].push(msg.sender);
        
        portions[lastPortionId].hashId = dataStorage.add(_base64);
        portions[lastPortionId].hasValue = true;
        
        portionsByOwner[msg.sender].push(lastPortionId);
        
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
        if (!portions[_portionId].hasValue) revert('Element does not exist');
        portionTerms[_portionId].price = _price;
        portionTerms[_portionId].duration = now + _duration;
        portionTerms[_portionId].expectedProduction = _expectedProduction;
        portionTerms[_portionId].periodicity = _periodicity;
        portionTerms[_portionId].expectedMaintenanceCost = _expectedMaintenanceCost;
        portionTerms[_portionId].expectedProdActivityCost = _expectedProdActivityCost;
    }
    
    function sell(uint256 _id, address _buyer) external onlyOwnerAndBuyer(_id) { //sell and transfer ownership
        if (!portions[_id].hasValue) revert('Element does not exist');
        portionTerms[_id].buyer = _buyer;
        portionsByBuyer[_buyer].push(_id);
        
        buyersByPortions[_id].push(_buyer);
    }
    
    function ownershipExpiration(uint256 _id) external {
        if (!portions[_id].hasValue) revert('Element does not exist');
        if (portionTerms[_id].duration == 0 || now < portionTerms[_id].duration) revert('Owneship expiration not allowed');
        portionTerms[_id].buyer = address(0);
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

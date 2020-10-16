// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

//import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

import './Storage.sol';
import './Product.sol';
import './Maintenance.sol';
import './ProductionActivity.sol';

/// @title Contract representing a portion of land
contract Portion {
    using SafeMath for uint256;
    
    /// @dev Portion data
    struct Data {
        uint256 land;
        string description;
        uint256 hashId;
        bool hasValue;
    }
    
    /// @notice Duration parameter can be perpetual (0) or for n years
    struct TermsOfSale {
        uint256 price;
        uint256 duration;
        string expectedProduction;
        string periodicity;
        uint256 expectedMaintenanceCost;
        uint256 expectedProdActivityCost;
        address owner;
        address buyer;
    }
    
    /// @dev All the portions
    mapping (uint256 => Data) private portions;
    /// @dev Portions grouped by land
    mapping (uint256 => uint256[]) private portionsByLand;
    /// @dev Portions grouped by owner's address
    mapping (address => uint256[]) private portionsByOwner;
    /// @dev Portions grouped by buyer's address
    mapping (address => uint256[]) private portionsByBuyer;
    /// @dev All the portion terms
    mapping (uint256 => TermsOfSale) private portionTerms;
    /// @dev Buyers grouped by portion
    mapping (uint256 => address[]) buyersByPortions;
    
    /// @dev Portion counter
    uint256 private lastPortionId;
    
    /// @dev Storage contract instance
    Storage private dataStorage;
    
    /// @param _dataStorage Storage contract address
    constructor (address _dataStorage) public  {
        dataStorage = Storage(_dataStorage);
    }
    
    /// @dev Portion terms can be defined only by the portion owner
    modifier onlyOwner(uint256 _portionId) {
        require(portionTerms[_portionId].owner == msg.sender, 'Only owner is allowed');
        _;
    }
    
    /// @dev Selling or transferring ownership can be performed only by owner or buyer
    modifier onlyOwnerAndBuyer(uint256 _portionId) {
        require(portionTerms[_portionId].owner == msg.sender || portionTerms[_portionId].buyer == msg.sender, 'Only owner or buyer are allowed');
        _;
    }
    
    /// @param _landId Land to be divided
    /// @param _description Portion description
    /// @param _base64 Base64 encoded documents
    /// @return the hash of the document
    function register(uint256 _landId, string calldata _description, string calldata _base64) external returns (bytes32) {
        portionsByLand[_landId].push(lastPortionId);
        
        portions[lastPortionId].description = _description;
        portions[lastPortionId].land = _landId;
        
        portions[lastPortionId].hashId = dataStorage.add(_base64);
        portions[lastPortionId].hasValue = true;
        
        lastPortionId++;

        return dataStorage.getById(lastPortionId - 1);
    }

    /// @param _landId Land to be divided
    /// @param _description Portion description
    /// @param _base64 Base64 encoded documents
    /// @param _source Original sender from divide land
    function register(uint256 _landId, string calldata _description, string calldata _base64, address _source) external {
        portionTerms[lastPortionId].owner = _source;
        portionsByOwner[_source].push(lastPortionId);        
        buyersByPortions[lastPortionId].push(_source);

        this.register(_landId, _description, _base64);
    }
    
    /// @param _portionId ID of portion related
    /// @param _price Contract price
    /// @param _duration Contract duration
    /// @param _expectedProduction Production expected from the portion
    /// @param _periodicity Production periodicity
    /// @param _expectedMaintenanceCost Costs expected for maintenance
    /// @param _expectedProdActivityCost Costs expected for production-related activities 
    function defineTerms(
        uint256 _portionId,
        uint256 _price,
        uint256 _duration,
        string calldata _expectedProduction,
        string calldata _periodicity,
        uint256 _expectedMaintenanceCost,
        uint256 _expectedProdActivityCost
    ) external onlyOwner(_portionId) {
        portionTerms[_portionId].price = _price;
        portionTerms[_portionId].duration = _duration;
        portionTerms[_portionId].expectedProduction = _expectedProduction;
        portionTerms[_portionId].periodicity = _periodicity;
        portionTerms[_portionId].expectedMaintenanceCost = _expectedMaintenanceCost;
        portionTerms[_portionId].expectedProdActivityCost = _expectedProdActivityCost;
    }
    
    /// @notice Sell and transfer ownership
    /// @param _id Portion ID
    /// @param _buyer New buyer
    function sell(uint256 _id, address _buyer) external onlyOwnerAndBuyer(_id) {
        portionTerms[_id].buyer = _buyer;
        portionsByBuyer[_buyer].push(_id);
        
        buyersByPortions[_id].push(_buyer);
    }
    
    /// @param _id Portion ID
    function ownershipExpiration(uint256 _id) external {
        if (!portions[_id].hasValue) revert('Element does not exist');
        if (portionTerms[_id].duration == 0 || now < portionTerms[_id].duration) revert('Owneship expiration not allowed');
        portionTerms[_id].buyer = address(0);
    }
    
    /// @param _id Portion ID
    /// return the tuple containing the data related to the portion and its terms of sale
    function getById(uint256 _id) external view returns (Data memory, TermsOfSale memory, bytes32) {
        return (portions[_id], portionTerms[_id], dataStorage.getById(_id));
    }

    /// @param _land Land ID
    /// return the array containing all the portions in a land
    function getByLand(uint256 _land) external view returns (uint256[] memory) {
        return (portionsByLand[_land]);
    }
    
    /// @param _owner Owner address
    /// @return the array containing all the portions owned
    function getByOwner(address _owner) external view returns (uint256[] memory) {
        return portionsByOwner[_owner];
    }

    /// @param _buyer Buyer address
    /// @return the array containing all the portions bought
    function getByBuyer(address _buyer) external view returns (uint256[] memory) {
        return portionsByBuyer[_buyer];
    }
    
    /// @param _id Portion ID
    /// @return the array containing all the buyers for that portion
    function getBuyersByPortion(uint256 _id) external view returns (address[] memory) {
        return buyersByPortions[_id];
    }
    
    /// @return the number of registered portions
    function getTotal() external view returns (uint256) {
        return lastPortionId;
    }
    
    /// @param _description Product description
    /// @param _id Portion ID for registering the product
    /// @param _contractAddress Product contract address
    function registerProduct(string calldata _description, uint256 _id, address _contractAddress) external {
        if (!portions[_id].hasValue) revert('Element does not exist');
        Product(_contractAddress).register(_description, _id, msg.sender);
    }
    
    /// @param _description Production description
    /// @param _id Portion ID for registering the production
    /// @param _contractAddress Production contract address
    function registerProductionActivity(string calldata _description, uint256 _id, address _contractAddress) external {
        if (!portions[_id].hasValue) revert('Element does not exist');
        ProductionActivity(_contractAddress).register(_description, _id, msg.sender);
    }
    
    /// @param _description Maintenance description
    /// @param _id Portion ID for registering the maintenance
    /// @param _contractAddress Maintenance contract address
    function registerMaintenance(string calldata _description, uint256 _id, address _contractAddress) external {
        if (!portions[_id].hasValue) revert('Element does not exist');
        Maintenance(_contractAddress).register(_description, _id, msg.sender);
    }
    
}

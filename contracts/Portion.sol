// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

//import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

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
        bytes32[] documents;
        bytes32[] hashes;
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
    mapping (uint256 => address[]) private buyersByPortions;
    // Useful for showing history

    /// @dev This is a mapping that contains, for each portion (key) the index corresponding in the portionsByOwner[address] array
    // This can be useful when the contract is perpetual and the old owner must be replaced by the new buyer.
    mapping (uint256 => uint256) private portionOwnerIndexByPortion;
    // There is only one owner for portion.

    /// @dev This is a mapping that contains, for each portion (key) the index corresponding in the portionsByBuyer[address] array
    // This can be useful when the portion is sold and the old buyer must be replaced by the new buyer.
    mapping (uint256 => uint256) private portionBuyerIndexByPortion;
    // There is only one owner for portion.
    
    /// @dev Portion counter
    uint256 private lastPortionId;
    
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
    function register(uint256 _landId, string memory _description) public {
        portions[lastPortionId + 1].description = portions[lastPortionId].description = _description;
        portions[lastPortionId + 1].land = portions[lastPortionId].land = _landId;
        
        portions[lastPortionId + 1].hasValue = portions[lastPortionId].hasValue = true;
        
        lastPortionId += 2;
    }

    /// @param _landId Land to be divided
    /// @param _description Portion description
    /// @param _source Original sender from divide land
    function register(uint256 _landId, string memory _description, address _source) public {
        if (portionsByLand[_landId].length == 2) revert ('Portion cannot be created');

        portionsByLand[_landId].push(lastPortionId);
        portionsByLand[_landId].push(lastPortionId + 1);

        portionTerms[lastPortionId + 1].owner = portionTerms[lastPortionId].owner = _source;

        portionsByOwner[_source].push(lastPortionId);
        portionsByOwner[_source].push(lastPortionId + 1);

        portionOwnerIndexByPortion[lastPortionId] = portionsByOwner[_source].length - 2;
        portionOwnerIndexByPortion[lastPortionId + 1] = portionsByOwner[_source].length - 1;

        this.register(_landId, _description);
    }

    /// @param _id Portion ID
    /// @param _document Document name
    /// @param _base64 Base64 document
    function registerDocument(uint256 _id, bytes32 _document, bytes32 _base64) external onlyOwner(_id) {
        portions[_id].documents.push(_document);
        portions[_id].hashes.push(_base64);
    }
    
    /// @param _portionId ID of portion related
    /// @param _price Contract price
    /// @param _duration Contract duration
    /// @param _expectedProduction Production expected from the portion
    /// @param _periodicity Production periodicity
    /// @param _expectedMaintenanceCost Costs expected for maintenance
    /// @param _expectedProdActivityCost Costs expected for production-related activities 
    /// @param _buyer New buyer
    function defineTerms(
        uint256 _portionId,
        uint256 _price,
        uint256 _duration,
        string calldata _expectedProduction,
        string calldata _periodicity,
        uint256 _expectedMaintenanceCost,
        uint256 _expectedProdActivityCost,
        address _buyer
    ) external onlyOwner(_portionId) {
        portionTerms[_portionId].price = _price;
        portionTerms[_portionId].duration = _duration;
        portionTerms[_portionId].expectedProduction = _expectedProduction;
        portionTerms[_portionId].periodicity = _periodicity;
        portionTerms[_portionId].expectedMaintenanceCost = _expectedMaintenanceCost;
        portionTerms[_portionId].expectedProdActivityCost = _expectedProdActivityCost;

        this.sell(_portionId, _buyer, msg.sender);
    }

    /// @notice Sell and transfer ownership
    /// @param _id Portion ID
    /// @param _buyer New buyer
    /// @param _source Sender
    function sell(uint256 _id, address _buyer, address _source) public {
        if (!(portionTerms[_id].owner == _source || portionTerms[_id].buyer == _source)) revert ('Only owner or buyer are allowed');

        if (portionTerms[_id].duration != 0) {
            // If the portion was already sold
            if (portionTerms[_id].buyer != address(0)) {
                if (portionsByBuyer[portionTerms[_id].buyer].length != 1 && portionBuyerIndexByPortion[_id] != portionsByBuyer[portionTerms[_id].buyer].length - 1) {
                    // The portion is removed from the old buyers's array
                    portionsByBuyer[portionTerms[_id].buyer][portionBuyerIndexByPortion[_id]] = portionsByBuyer[portionTerms[_id].buyer][portionsByBuyer[portionTerms[_id].buyer].length - 1];
                }
                portionsByBuyer[portionTerms[_id].buyer].pop();
            }

            // Update buyer
            portionTerms[_id].buyer = _buyer;
            portionsByBuyer[_buyer].push(_id);
            buyersByPortions[_id].push(_buyer);

            // Update the support variable
            portionBuyerIndexByPortion[_id] = portionsByBuyer[_buyer].length - 1;

        } else {

            if (portionsByOwner[portionTerms[_id].owner].length != 1 && portionOwnerIndexByPortion[_id] != portionsByOwner[portionTerms[_id].owner].length - 1) {
                // The portion is removed from the old owner's array
                portionsByOwner[portionTerms[_id].owner][portionOwnerIndexByPortion[_id]] = portionsByOwner[portionTerms[_id].owner][portionsByOwner[portionTerms[_id].owner].length - 1];
            }
            portionsByOwner[portionTerms[_id].owner].pop();

            // Update owner
            portionTerms[_id].owner = _buyer;
            portionsByOwner[_buyer].push(_id);

            // Update the support variable
            portionOwnerIndexByPortion[_id] = portionsByOwner[_buyer].length - 1;
        }      
    }
    
    /// @notice Sell and transfer ownership
    /// @param _id Portion ID
    /// @param _buyer New buyer
    function sell(uint256 _id, address _buyer) external onlyOwnerAndBuyer(_id) {
        if (_buyer == portionTerms[_id].buyer || _buyer == portionTerms[_id].owner) revert('Address not valid for this operation');
        
        this.sell(_id, _buyer, msg.sender);
    }
    
    /// @param _id Portion ID
    function ownershipExpiration(uint256 _id) external {
        if (!portions[_id].hasValue) revert('Element does not exist');
        if (portionTerms[_id].duration == 0 || now < portionTerms[_id].duration) revert('Owneship expiration not allowed');
        if (portionTerms[_id].buyer == address(0)) revert('Buyer is not set');

        if (portionsByBuyer[portionTerms[_id].buyer].length != 1 && portionBuyerIndexByPortion[_id] != portionsByBuyer[portionTerms[_id].buyer].length - 1) {
            // The portion is removed from the old buyers's array
            portionsByBuyer[portionTerms[_id].buyer][portionBuyerIndexByPortion[_id]] = portionsByBuyer[portionTerms[_id].buyer][portionsByBuyer[portionTerms[_id].buyer].length - 1];
        }
        portionsByBuyer[portionTerms[_id].buyer].pop();
        portionTerms[_id].buyer = address(0);

    }
    
    /// @param _id Portion ID
    /// return the tuple containing the data related to the portion and its terms of sale
    function getById(uint256 _id) external view returns (Data memory, TermsOfSale memory) {
        return (portions[_id], portionTerms[_id]);
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

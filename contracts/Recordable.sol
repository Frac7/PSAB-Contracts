// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

//import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

/// @title Contract representing a recordable item
contract Recordable {    
    using SafeMath for uint256;
    
    /// @dev Data related to the item to be registered
    struct Data {
        string description;
        uint256 portion;
        address registeredBy;
    }
    
    /// @dev All the items
    mapping (uint256 => Data) private items;
    /// @dev Items grouped by operator's address
    mapping (address => uint256[]) private itemsByOperators;
    /// @dev Items grouped by the related portion
    mapping (uint256 => uint256[]) private itemsByPortions;
    
    /// @dev Items counter
    uint256 lastId;

    /// @param _description Item description
    /// @param _id Related portion ID
    function register(string calldata _description, uint256 _id) private {
        items[lastId].description = _description;
        items[lastId].portion = _id;
        
        itemsByPortions[_id].push(lastId);
        
        lastId++;
    }

    /// @param _description Item description
    /// @param _id Related portion ID
    /// @param _source Original sender
    function register(string calldata _description, uint256 _id, address _source) external {
        items[lastId].registeredBy = _source;
        itemsByOperators[_source].push(lastId);

        this.register(_description, _id);        
    }

    /// @param _id Item ID
    /// @return the item data only if the item exists
    function getById(uint256 _id) external view returns (Data memory) {
        return items[_id];
    }
    
    /// @param _address Operator's address
    /// @return the array containing all the item IDs registered by a specific operator
    function getByOperator(address _address) external view returns (uint256[] memory) {
        return itemsByOperators[_address];
    }
    
    /// @param _id Portion ID
    /// @return the array containing all the the item IDs registered in a specific portion
    function getByPortion(uint256 _id) external view returns (uint256[] memory) {
        return itemsByPortions[_id];
    }
    
    /// @return the number of registerd items
    function getTotal() external view returns (uint256) {
        return lastId;
    }
}

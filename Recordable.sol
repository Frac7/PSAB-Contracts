// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

contract Recordable {
    using SafeMath for uint256;
    
    struct Data {
        string description;
        uint256 portion;
        address registerdBy;
    }
    
    mapping (uint256 => Data) private items;
    mapping (address => uint256[]) private itemsByOperators;
    mapping (uint256 => uint256[]) private itemsByPortions;
    
    uint lastId;

    function register(string calldata _description, uint256 _id) external {
        items[lastId].description = _description;
        items[lastId].portion = _id;
        items[lastId].registerdBy = msg.sender;
        
        
        itemsByOperators[msg.sender].push(lastId);
        
        itemsByPortions[_id].push(lastId);
        
        lastId++;
    }
    
    function getById(uint256 _id) public view returns (Data memory) {
        if (items[_id].registerdBy == address(0)) revert('Element does not exist');
        return items[_id];
    }
    
    function getByOperator(address _address) external view returns (uint256[] memory) {
        return itemsByOperators[_address];
    }
    
    function getByPortion(uint256 _id) external view returns (uint256[] memory) {
        return itemsByPortions[_id];
    }
    
    function getTotal() external view returns (uint256) {
        return lastId;
    }
}

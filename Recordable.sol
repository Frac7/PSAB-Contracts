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
    
    struct Operator {
        uint256[] itemRegistered;
    }
    
    struct Portion {
        uint256[] itemPerformed;
    }
    
    mapping (uint256 => Data) private items;
    mapping (address => Operator) private operators;
    mapping (uint256 => Portion) private portions;
    
    uint lastId;

    function register(string calldata _description, uint256 _id) external {
        items[lastId].description = _description;
        items[lastId].portion = _id;
        items[lastId].registerdBy = msg.sender;
        
        
        operators[msg.sender].itemRegistered.push(lastId);
        
        portions[_id].itemPerformed.push(lastId);
        
        lastId++;
    }
    
    function getById(uint256 _id) external view returns (Data memory) {
        return items[_id];
    }
    
    function getByOperator(address _address) external view returns (Operator memory) {
        return operators[_address];
    }
    
    function getByPortion(uint256 _id) external view returns (Portion memory) {
        return portions[_id];
    }
    
    function getTotal() external view returns (uint256) {
        return lastId;
    }
}

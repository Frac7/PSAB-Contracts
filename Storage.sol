// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2; 

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

contract Storage {
    using SafeMath for uint256;
    
    mapping (uint256 => bytes32) private items;
    uint private lastItemId;
    
    function add(bytes32[] memory _item) public returns(uint256){
        items[lastItemId] = keccak256(abi.encodePacked(_item));
        lastItemId++;
        
        return lastItemId - 1;
    }
    
    function getById(uint256 id) public view returns(bytes32) {
        return items[id];
    }
}

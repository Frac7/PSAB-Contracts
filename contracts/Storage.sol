// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2; 

//import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

/// @title Contract for storing hased base64 documents
contract Storage {    
    using SafeMath for uint256;
    
    /// @dev Hashes by ID
    mapping (uint256 => bytes32) private items;
    /// @dev Hashes counter
    uint private lastItemId;
    
    /// @param _item Base64 document
    /// @return the ID of the hash
    function add(string memory _item) public returns(uint256) {
        items[lastItemId] = keccak256(abi.encodePacked(_item));
        lastItemId++;
        
        return lastItemId - 1;
    }
    
    /// @param _id Hash ID
    /// @return the hash related to the ID
    function getById(uint256 _id) public view returns(bytes32) {
        return items[_id];
    }
}

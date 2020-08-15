// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2; 

import '@openzeppelin/contracts/math/SafeMath.sol';

contract Storage {
    using SafeMath for uint256;

    struct Item {
        bytes32 itemHash;
        //...
    }
    
    //TODO: improve and change this mechanism
    mapping (uint256 => Item) private items;
    uint private lastItemId;
    
    function add(bytes32 _item) public {
        items[lastItemId] = Item({ itemHash: keccak256(abi.encodePacked(_item)) });
        lastItemId++;
    }
    
    function get(uint256 id) public view returns(Item memory) {
        return items[id];
    }
}
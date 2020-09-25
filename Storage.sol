// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2; 

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

contract Storage {
    using SafeMath for uint256;

    struct Item {
        bytes32 itemHash;
        string link;
    }
    
    mapping (uint256 => Item) private items;
    uint private lastItemId;
    
    function add(bytes32 _item, string memory _link) public returns(uint256) {
        items[lastItemId] = Item({ itemHash: keccak256(abi.encodePacked(_item)), link: _link });
        lastItemId++;
        
        return lastItemId - 1;
    }
    
    function get(uint256 id) public view returns(Item memory) {
        return items[id];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

contract Product {
    using SafeMath for uint256;

    struct Data {
        string name;
        address registerdBy; //operator address
        //TODO: which information needs to be saved?
    }
    
    struct Operator {
        uint256[] productsRegistered;
    }
    
    mapping (uint256 => Data) private products;
    mapping (address => Operator) private operators;
    
    uint256 lastProductId;
    
    modifier onlyOperator(uint256 _productId) {
        require(products[_productId].registerdBy == msg.sender);
        _;
    }

    //TODO: getters and setters
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

contract Product {
    using SafeMath for uint256;
    
    struct Certification {
        string description;
        address certifier;
    }

    struct Data {
        string description;
        uint256 portion;
        address registerdBy;
        Certification[] certifications;
    }
    
    struct Operator {
        uint256[] productsRegistered;
    }
    
    struct Certifier {
        uint256[] productsCertified;
    }
    
    struct Portion {
        uint256[] products;
    }
    
    mapping (uint256 => Data) private products;
    mapping (address => Operator) private operators;
    mapping (address => Certifier) private certifiers;
    mapping (uint256 => Portion) private portions;
    
    uint256 lastProductId;
    
    modifier onlyOperator(uint256 _productId) {
        require(products[_productId].registerdBy == msg.sender);
        _;
    }

    function register(string calldata _description, uint256 _id) external {
        products[lastProductId].description = _description;
        products[lastProductId].portion = _id;
        products[lastProductId].registerdBy = msg.sender;
        
        
        operators[msg.sender].productsRegistered.push(lastProductId);
        
        portions[_id].products.push(lastProductId);
        
        lastProductId++;
    }
    
    function certify(uint256 _id, string calldata _description) external {
        Certification memory certification;
        certification.description = _description;
        certification.certifier = msg.sender;
        
        products[_id].certifications.push(certification);
        certifiers[msg.sender].productsCertified.push(_id);
    }
    
    function getById(uint256 _id) external view returns (Data memory) {
        return products[_id];
    }
    
    function getByOperator(address _address) external view returns (Operator memory) {
        return operators[_address];
    }
    
    function getByPortion(uint256 _id) external view returns (Portion memory) {
        return portions[_id];
    }
    
    function getTotalProducts() external view returns (uint256) {
        return lastProductId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract ProductionActivity {
    using SafeMath for uint256;

    struct Data {
        string name;
        address registerdBy; //operator address
        //TODO: which information needs to be saved?
    }
    
    struct Operator {
        uint256[] productionActivityRegistered;
    }
    
    mapping (uint256 => Data) private productionActivities;
    mapping (address => Operator) private operators;
    
    uint lastProductionActivityId;
    
    modifier onlyOperator(uint256 _productionActivityId) {
        require(productionActivities[_productionActivityId].registerdBy == msg.sender);
        _;
    }

    //TODO: getters and setters
}
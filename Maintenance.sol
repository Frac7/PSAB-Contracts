// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

contract Maintenance {
    using SafeMath for uint256;

    struct Data {
        string name;
        address registerdBy; //operator address
        //TODO: which information needs to be saved?
    }
    
    struct Operator {
        uint256[] maintenanceRegistered;
    }
    
    mapping (uint256 => Data) private maintenances;
    mapping (address => Operator) private operators;
    
    uint lastMaintenanceId;
    
    modifier onlyOperator(uint256 _maintenanceId) {
        require(maintenances[_maintenanceId].registerdBy == msg.sender);
        _;
    }

    //TODO: getters and setters
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

contract Maintenance {
    using SafeMath for uint256;
    
    struct Data {
        string description;
        uint256 portion;
        address registerdBy;
    }
    
    struct Operator {
        uint256[] maintenancesRegistered;
    }
    
    struct Portion {
        uint256[] maintenancesPerformed;
    }
    
    mapping (uint256 => Data) private maintenances;
    mapping (address => Operator) private operators;
    mapping (uint256 => Portion) private portions;
    
    uint lastMaintenanceId;

    function register(string calldata _description, uint256 _id) external {
        maintenances[lastMaintenanceId].description = _description;
        maintenances[lastMaintenanceId].portion = _id;
        maintenances[lastMaintenanceId].registerdBy = msg.sender;
        
        
        operators[msg.sender].maintenancesRegistered.push(lastMaintenanceId);
        
        portions[_id].maintenancesPerformed.push(lastMaintenanceId);
        
        lastMaintenanceId++;
    }
    
    function getById(uint256 _id) external view returns (Data memory) {
        return maintenances[_id];
    }
    
    function getByOperator(address _address) external view returns (Operator memory) {
        return operators[_address];
    }
    
    function getByPortion(uint256 _id) external view returns (Portion memory) {
        return portions[_id];
    }
}

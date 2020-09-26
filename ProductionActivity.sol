// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

contract ProductionActivity {
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
        uint256[] activitiesRegistered;
    }
    
    struct Certifier {
        uint256[] activitiesCertified;
    }
    
    struct Portion {
        uint256[] activitiesPerformed;
    }
    
    mapping (uint256 => Data) private activities;
    mapping (address => Operator) private operators;
    mapping (address => Certifier) private certifiers;
    mapping (uint256 => Portion) private portions;
    
    uint256 lastActivityId;

    function register(string calldata _description, uint256 _id) external {
        activities[lastActivityId].description = _description;
        activities[lastActivityId].portion = _id;
        activities[lastActivityId].registerdBy = msg.sender;
        
        
        operators[msg.sender].activitiesRegistered.push(lastActivityId);
        
        portions[_id].activitiesPerformed.push(lastActivityId);
        
        lastActivityId++;
    }
    
    function certify(uint256 _id, string calldata _description) external {
        Certification memory certification;
        certification.description = _description;
        certification.certifier = msg.sender;
        
        activities[_id].certifications.push(certification);
        certifiers[msg.sender].activitiesCertified.push(_id);
    }
    
    function getById(uint256 _id) external view returns (Data memory) {
        return activities[_id];
    }
    
    function getByOperator(address _address) external view returns (Operator memory) {
        return operators[_address];
    }
    
    function getByCertifier(address _address) external view returns (Certifier memory) {
        return certifiers[_address];
    }
    
    function getByPortion(uint256 _id) external view returns (Portion memory) {
        return portions[_id];
    }
    
    function getTotalProdActivities() external view returns (uint256) {
        return lastActivityId;
    }
}

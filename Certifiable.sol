// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

contract Certifiable {
    using SafeMath for uint256;
    
    struct Certification {
        string description;
        address certifier;
        uint256 item;
    }
    
    uint256 lastId;
    
    mapping (uint256 => uint256[]) private certificationsByItem;
    mapping (uint256 => Certification) private certifications;
    mapping (address => uint256[]) private certificationsByCertifiers;
    
    function certify(uint256 _id, string calldata _description) external {
        certifications[lastId].description = _description;
        certifications[lastId].certifier = msg.sender;
        certifications[lastId].item = _id;
        
        certificationsByCertifiers[msg.sender].push(_id);
        
        certificationsByItem[_id].push(lastId);
        
        lastId ++;
    }
    
    
    
    function getCertificationById(uint256 _id) external view returns (Certification memory) {
        return certifications[_id];
    }
    
    function getByCertifier(address _address) external view returns (uint256[] memory) {
        return certificationsByCertifiers[_address];
    }
    
    function getByItem(uint256 _id) external view returns (uint256[] memory) {
        return certificationsByItem[_id];
    }
    
    function getTotalCertification() external view returns (uint256) {
        return lastId;
    }
}

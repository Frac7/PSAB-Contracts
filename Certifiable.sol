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
    
    uint256 private lastCertificationId;
    
    mapping (uint256 => uint256[]) private certificationsByItem;
    mapping (uint256 => Certification) private certifications;
    mapping (address => uint256[]) private certificationsByCertifiers;
    
    function certify(uint256 _id, string calldata _description) external {
        certifications[lastCertificationId].description = _description;
        certifications[lastCertificationId].certifier = msg.sender;
        certifications[lastCertificationId].item = _id;
        
        certificationsByCertifiers[msg.sender].push(_id);
        
        certificationsByItem[_id].push(lastCertificationId);
        
        lastCertificationId ++;
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
}

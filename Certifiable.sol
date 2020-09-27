// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';

contract Certifiable {
    using SafeMath for uint256;
    
    struct Certification {
        string description;
        address certifier;
    }
    
    uint256 private lastCertificationId;
    
    mapping (uint256 => Certification) private certifications;
    mapping (address => uint256[]) private certificationsByCertifiers;
    
    function certify(uint256 _id, string calldata _description) external {
        certifications[lastCertificationId].description = _description;
        certifications[lastCertificationId].certifier = msg.sender;
        
        certificationsByCertifiers[msg.sender].push(_id);
        
        lastCertificationId ++;
    }
    
    function getCertificationById(uint256 _id) external view returns (Certification memory) {
        return certifications[_id];
    }
    
    function getByCertifier(address _address) external view returns (uint256[] memory) {
        return certificationsByCertifiers[_address];
    }
}

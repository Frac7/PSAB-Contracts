// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

//import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

/// @title Certifiable item
contract Certifiable {    
    using SafeMath for uint256;
    
    /// @dev A certification is represented by a description and the certifier's address
    struct Certification {
        string description;
        address certifier;
    }
    
    /// @dev Certifications counter
    uint256 private lastCertificationId;
    
    /// @dev All certifications registered
    mapping (uint256 => Certification) private certifications;
    /// @dev Certification IDs grouped by certifier's address
    mapping (address => uint256[]) private certificationsByCertifiers;
    /// @dev Certification IDs grouped by the related item
    mapping (uint256 => uint256[]) private certificationsByItems;
    
    /// @param _id Item to be certified
    /// @param _description Certification description
    function certify(uint256 _id, string calldata _description) external {
        certifications[lastCertificationId].description = _description;
        certifications[lastCertificationId].certifier = msg.sender;
        
        certificationsByItems[_id].push(_id);
        
        certificationsByCertifiers[msg.sender].push(_id);
        
        lastCertificationId ++;
    }
    
    /// @param _id Item for which to retrieve certifications
    /// @return the related certification
    function getCertificationById(uint256 _id) external view returns (Certification memory) {
        return certifications[_id];
    }
    
    /// @param _address Certifier address for which to retrieve certifications
    /// @return the array containing all the certifications perfomed by a specific certifier
    function getByCertifier(address _address) external view returns (uint256[] memory) {
        return certificationsByCertifiers[_address];
    }
    
    /// @param _item Item ID for which to retrieve certifications
    /// @return the array containing all the certifications related to a specific item
    function getByItem(uint256 _item) external view returns (uint256[] memory) {
        return certificationsByItems[_item];
    }
}

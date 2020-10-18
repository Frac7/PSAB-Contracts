// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

//import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

import './Portion.sol';

/// @title This contract represents a land/agricultural resource
contract Land {
    
    using SafeMath for uint256;
    
    /// @dev Land data
    struct Data {
        string description;
        bytes32[] documents;
        bytes32[] hashes;
    }
    
    /// @dev All the lands
    mapping (uint256 => Data) private lands;
    /// @dev Land indices grouped by owners
    mapping (address => uint256[]) private landsByOwner;
    /// @dev Owners grouped by land IDs
    mapping (uint256 => address) private ownersByLandId;
    
    /// @dev Lands counter
    uint256 private lastLandId;
    
    /// @dev Only owner can perform operation in his land
    modifier onlyOwner(uint256 _landId) {
        require(ownersByLandId[_landId] == msg.sender, 'Only owner is allowed');
        _;
    }
    
    /// @param _description Land description
    function register(string calldata _description) external {
        landsByOwner[msg.sender].push(lastLandId);
        ownersByLandId[lastLandId] = msg.sender;
        
        lands[lastLandId].description = _description;
        
        lastLandId++;
    }

    /// @param _id Land ID
    /// @param _document Document name
    /// @param _base64 Base64 document
    function registerDocument(uint256 _id, bytes32 _document, bytes32 _base64) external onlyOwner(_id) {
        lands[_id].documents.push(_document);
        lands[_id].hashes.push(_base64);
    }
    
    /// @dev Only owner can divide a land in portion. This method calls the Portion instance for registering a new portion starting from input data.
    /// @param _id Land ID to divide
    /// @param _description Portion description
    /// @param _contractAddress Address of Portion contract    
    function divide(uint256 _id, string calldata _description, address _contractAddress) external onlyOwner(_id) {
        Portion(_contractAddress).register(_id, _description, msg.sender);
    }
    
    /// @param _id Land ID
    /// @return the data of the land
    function getById(uint256 _id) external view returns (Data memory) {
        return lands[_id];
    }
    
    /// @param _address Owner's address
    /// @return the array containing ID of lands owned
    function getByOwner(address _address) external view returns (uint256[] memory) {
        return landsByOwner[_address];
    }
    
    /// @param _id Land ID
    /// @return the address of the owner
    function getOwnerByLand(uint256 _id) external view returns (address) {
        return ownersByLandId[_id];
    }
    
    /// @return the total number of lands
    function getTotal() external view returns (uint256) {
        return lastLandId;
    }
}

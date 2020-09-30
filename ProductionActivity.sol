// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

//import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';


import './Recordable.sol';
import './Certifiable.sol';

/// @title Production activity contract. A production activity is recordable by an operator and certifiable by a certifier.
contract ProductionActivity is Recordable, Certifiable {
    
    /// @param _id Production activity ID
    /// @param _description Description of certification
    function certifyProduction(uint256 _id, string calldata _description) external {
        if (this.getById(_id).registeredBy == address(0)) revert('Element does not exist');
        this.certify(_id, _description);
    }
}

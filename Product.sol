// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';
import './Recordable.sol';
import './Certifiable.sol';

/// @title Product item contract. A product is recordable by an operator and certifiable by a certifier.
contract Product is Recordable, Certifiable {
    
    /// @param _id Product ID
    /// @param _description Description of certification
    function certifyProduct(uint256 _id, string calldata _description) external {
        if (this.getById(_id).registeredBy == address(0)) revert('Element does not exist');
        this.certify(_id, _description);
    }
}

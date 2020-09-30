// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';
import './Recordable.sol';
import './Certifiable.sol';

contract Product is Recordable, Certifiable {
    function certifyProduct(uint256 _id, string calldata _description) external {
        if (this.getById(_id).registeredBy == address(0)) revert('Element does not exist');
        this.certify(_id, _description);
    }
}

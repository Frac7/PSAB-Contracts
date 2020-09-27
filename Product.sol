// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '../../OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol';
import './Recordable.sol';
import './Certifiable.sol';

contract Product is Recordable, Certifiable {}

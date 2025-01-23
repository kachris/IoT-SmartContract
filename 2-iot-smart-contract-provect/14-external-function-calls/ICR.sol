// SPDX-License-Identifier: MIT

// WARNING: This smart contract is for testing and educational purposes only.
// DO NOT USE in production environments as it may contain vulnerabilities

pragma solidity 0.8.26;

import {ICRManager} from "./ICRManager.sol";

contract ICR is ICRManager {
    constructor(address _owner) ICRManager(_owner) {}
}

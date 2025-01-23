// SPDX-License-Identifier: MIT

// WARNING: This smart contract is for testing and educational purposes only.
// DO NOT USE in production environments as it may contain vulnerabilities

pragma solidity 0.8.26;

import {ICR} from "./ICR.sol";

contract ICRFactory {
    error ICRFactory__AlreadyHasSmartContract(address _user);
    error ICRFactory__UserCannotBeAddressZero();

    event IcrDeployed(uint256 indexed _icrId, address indexed _icrAddress, address indexed _icrOwner);

    mapping(uint256 _icrId => address _icrAddress) private s_icrs;
    uint256 private s_nextIcrId;

    mapping(address _user => bool _hasSc) private s_userHasSc;

    function deployICR(address _user) external {
        if (s_userHasSc[_user]) {
            revert ICRFactory__AlreadyHasSmartContract(_user);
        }
        if (_user == address(0)) {
            revert ICRFactory__UserCannotBeAddressZero();
        }
        s_userHasSc[_user] = true;
        uint256 newIcrId = s_nextIcrId;
        ICR icr = new ICR(_user);
        s_icrs[newIcrId] = address(icr);
        s_nextIcrId++;
        emit IcrDeployed(newIcrId, address(icr), icr.getOwner());
    }
}

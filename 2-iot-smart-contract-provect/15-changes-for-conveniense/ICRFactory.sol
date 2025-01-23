// SPDX-License-Identifier: MIT

// WARNING: This smart contract is for testing and educational purposes only.
// DO NOT USE in production environments as it may contain vulnerabilities

pragma solidity 0.8.26;

import {ICR} from "./ICR.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ICRFactory is Ownable, ReentrancyGuard {
    error ICRFactory__AlreadyHasSmartContract(address _user);
    error ICRFactory__UserCannotBeAddressZero();
    error ICRFactory__AddressIsMC(address _mc);
    error ICRFactory__NotValidICRId(uint256 _icrId);

    event CarRegisteredToICR(address indexed _icrAddress, uint256 indexed _carId, address indexed _mc);
    event IcrDeployed(uint256 indexed _icrId, address indexed _icrAddress, address indexed _icrOwner);

    mapping(uint256 _icrId => address _icrAddress) private s_icrs;
    uint256 private s_nextIcrId;

    mapping(address _user => bool _hasSc) private s_userHasSc;

    mapping(address _address => bool _isMc) private s_isMc;

    constructor() Ownable(msg.sender) {}

    function deployICR(address _user) external onlyOwner nonReentrant {
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

    function registerCarToICR(uint256 _icrId, uint256 _price, address _mc) external onlyOwner nonReentrant {
        if (s_isMc[_mc]) {
            revert ICRFactory__AddressIsMC(_mc);
        }
        if (_icrId >= s_nextIcrId) {
            revert ICRFactory__NotValidICRId(_icrId);
        }
        s_isMc[_mc] = true;
        address icrAddress = s_icrs[_icrId];
        ICR icr = ICR(icrAddress);
        emit CarRegisteredToICR(icrAddress, icr.getNextCarId(), _mc);
        icr.registerCar(_mc, _price);
    }
}

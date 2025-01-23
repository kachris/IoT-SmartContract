// SPDX-License-Identifier: MIT

// WARNING: This smart contract is for testing and educational purposes only.
// DO NOT USE in production environments as it may contain vulnerabilities

pragma solidity 0.8.26;

import {ICRRegistry} from "./ICRRegistry.sol";

contract ICRManager is ICRRegistry {
    event CarRented(uint256 indexed _carId, address indexed _mc, address indexed _user);
    event CarIsAvailable(uint256 indexed _carId, address indexed _mc);
    event CarIsUnavailable(uint256 indexed _carId, address indexed _mc);

    constructor(address _owner) ICRRegistry(_owner) {}

    function rentCar(uint256 _carId) public payable carIsValid(_carId) isPaused nonReentrant {
        if (msg.value < s_cars[_carId].price) {
            revert ICR__NotEnoughEther(msg.value);
        }
        if (s_cars[_carId].status != Status.AVAILABLE) {
            revert ICR__CarIsNotInTheCorrectStatus(_carId, s_cars[_carId].status);
        }
        if (s_cars[_carId].mc.balance <= MINIMUM_MC_BALANCE) {
            //here
            revert ICR__MCBalanceIsBelowMinimum(s_cars[_carId].mc, s_cars[_carId].mc.balance);
        }
        Car storage car = s_cars[_carId];
        car.status = Status.OCCUPIED;
        car.timeOfLastRent = block.timestamp;
        car.currentRenter = msg.sender;
        emit CarRented(_carId, car.mc, msg.sender);
    }

    function changeCarStatusMc(uint256 _carId) public carIsValid(_carId) nonReentrant {
        if (msg.sender != s_cars[_carId].mc) {
            revert ICR__IsNotMc(_carId, msg.sender);
        }
        if (s_cars[_carId].status != Status.OCCUPIED) {
            revert ICR__CarIsNotInTheCorrectStatus(_carId, s_cars[_carId].status);
        }
        if (s_cars[_carId].timeOfLastRent + RENT_TIME > block.timestamp) {
            revert ICR__RentingTimeIsNotOverYet(s_cars[_carId].timeOfLastRent + RENT_TIME, _carId);
        }
        Car storage car = s_cars[_carId];
        car.currentRenter = i_owner;
        if (car.mc.balance <= MINIMUM_MC_BALANCE) {
            //here
            car.status = Status.UNAVAILABLE;
            emit CarIsUnavailable(_carId, car.mc);
        } else {
            car.status = Status.AVAILABLE;
            emit CarIsAvailable(_carId, car.mc);
        }
    }

    function changeCarStatusOwner(uint256 _carId) public carIsValid(_carId) nonReentrant {
        if (msg.sender != i_owner) {
            revert ICR__IsNotOwner(msg.sender);
        }
        if (s_cars[_carId].status == Status.OCCUPIED) {
            revert ICR__CarIsNotInTheCorrectStatus(_carId, s_cars[_carId].status);
        }
        Car storage car = s_cars[_carId];
        if (car.status == Status.AVAILABLE) {
            car.status = Status.UNAVAILABLE;
            emit CarIsUnavailable(_carId, car.mc);
        } else {
            if (car.mc.balance <= MINIMUM_MC_BALANCE) {
                //here
                revert ICR__MCBalanceIsBelowMinimum(car.mc, car.mc.balance);
            }
            car.status = Status.AVAILABLE;
            emit CarIsAvailable(_carId, car.mc);
        }
    }
}

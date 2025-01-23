// SPDX-License-Identifier: MIT

// WARNING: This smart contract is for testing and educational purposes only.
// DO NOT USE in production environments as it may contain vulnerabilities

pragma solidity 0.8.26;

import {ICRRegistry} from "./ICRRegistry.sol";

contract ICRManager is ICRRegistry {
    event CarRented(uint256 indexed _carId, address indexed _mc, address indexed _user); // here we also emit the address of the user that rented the car.​
    event CarIsAvailable(uint256 indexed _carId, address indexed _mc);
    event CarIsUnavailable(uint256 indexed _carId, address indexed _mc);

    function rentCar(uint256 _carId) public payable carIsValid(_carId) {
        if (msg.value < cars[_carId].price) {
            revert ICR__NotEnoughEther(msg.value);
        }
        if (cars[_carId].status != Status.AVAILABLE) {
            revert ICR__CarIsNotInTheCorrectStatus(_carId, cars[_carId].status);
        }
        Car storage car = cars[_carId];
        car.status = Status.OCCUPIED;
        emit CarRented(_carId, car.mc, msg.sender);
    }

    function changeCarStatusMc(uint256 _carId) public carIsValid(_carId) {
        if (msg.sender != cars[_carId].mc) {
            revert ICR__IsNotMc(_carId, msg.sender);
        }
        if (cars[_carId].status != Status.OCCUPIED) {
            revert ICR__CarIsNotInTheCorrectStatus(_carId, cars[_carId].status);
        }
        Car storage car = cars[_carId];
        car.status = Status.AVAILABLE;
        emit CarIsAvailable(_carId, car.mc);
    }

    function changeCarStatusOwner(uint256 _carId) public carIsValid(_carId) {
        if (msg.sender != owner) {
            revert ICR__IsNotOwner(msg.sender);
        }
        if (cars[_carId].status == Status.OCCUPIED) {
            revert ICR__CarIsNotInTheCorrectStatus(_carId, cars[_carId].status);
        }
        Car storage car = cars[_carId];
        if (car.status == Status.AVAILABLE) {
            car.status = Status.UNAVAILABLE;
            emit CarIsUnavailable(_carId, car.mc);
        } else {
            car.status = Status.AVAILABLE;
            emit CarIsAvailable(_carId, car.mc);
        }
    }
}

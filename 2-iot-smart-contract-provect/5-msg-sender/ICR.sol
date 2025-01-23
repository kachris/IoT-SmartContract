// SPDX-License-Identifier: MIT

// WARNING: This smart contract is for testing and educational purposes only.
// DO NOT USE in production environments as it may contain vulnerabilities

pragma solidity 0.8.26;

contract ICR {
    enum Status {
        UNAVAILABLE,
        AVAILABLE,
        OCCUPIED
    }

    struct Car {
        address mc;
        uint256 price;
        Status status;
    }

    address public owner;

    mapping(uint256 _carId => Car _car) public cars;
    uint256 public nextCarId;

    constructor() {
        owner = msg.sender;
    }

    function registerCar(address _mc, uint256 _price) public {
        Car memory car = Car(_mc, _price, Status.UNAVAILABLE);
        uint256 currentCarId = nextCarId;
        cars[currentCarId] = car;
        nextCarId++;
    }

    function changCarOccupie(uint256 _carId, Status _status) public {
        if (_carId < nextCarId) {
            Car storage car = cars[_carId];
            car.status = _status;
        }
    }

    function getNextCarId() public view returns (uint256) {
        return nextCarId;
    }

    function getCar(uint256 _carId) public view returns (Car memory) {
        return cars[_carId];
    }
}

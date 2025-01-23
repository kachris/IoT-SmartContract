// SPDX-License-Identifier: MIT

// WARNING: This smart contract is for testing and educational purposes only.
// DO NOT USE in production environments as it may contain vulnerabilities

pragma solidity 0.8.26;

contract ICR {
    error ICR__IsNotOwner(address _notOwner);
    error ICR__InvalidCar(uint256 _carId);
    error ICR__CarIsNotInTheCorrectStatus(uint256 _carId, Status _status);
    error ICR__IsNotMc(uint256 _carId, address _notMc);

    error ICR__NotEnoughEther(uint256 _price);
    error ICR__PriceIsTooSmall(uint256 _price);
    error ICR__PriceIsTooBig(uint256 _price);

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

    uint256 public LOWER_PRICE_LIMIT = 0.1 ether; // 0.1 ether = 10^17 wei​
    uint256 public UPPER_PRICE_LIMIT = 10 ether; // 10 ether = 10 * 10^18 wei
    address public owner;

    mapping(uint256 _carId => Car _car) public cars;
    uint256 public nextCarId;

    constructor() {
        owner = msg.sender;
    }

    function registerCar(address _mc, uint256 _price) public {
        if (msg.sender != owner) {
            revert ICR__IsNotOwner(msg.sender);
        }
        if (_price < LOWER_PRICE_LIMIT) {
            revert ICR__PriceIsTooSmall(_price);
        }
        if (_price > UPPER_PRICE_LIMIT) {
            revert ICR__PriceIsTooBig(_price);
        }
        Car memory car = Car(_mc, _price, Status.UNAVAILABLE);
        uint256 currentCarId = nextCarId;
        cars[currentCarId] = car;
        nextCarId++;
    }

    function rentCar(uint256 _carId) public payable carIsValid(_carId) {
        if (msg.value < cars[_carId].price) {
            revert ICR__NotEnoughEther(msg.value);
        }
        if (cars[_carId].status != Status.AVAILABLE) {
            revert ICR__CarIsNotInTheCorrectStatus(_carId, cars[_carId].status);
        }
        Car storage car = cars[_carId];
        car.status = Status.OCCUPIED;
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
        } else {
            car.status = Status.AVAILABLE;
        }
    }

    function getNextCarId() public view returns (uint256) {
        return nextCarId;
    }

    function getCar(uint256 _carId) public view returns (Car memory) {
        return cars[_carId];
    }

    modifier carIsValid(uint256 _carId) {
        if (_carId >= nextCarId) {
            revert ICR__InvalidCar(_carId);
        }
        _;
    }
}

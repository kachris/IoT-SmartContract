// SPDX-License-Identifier: MIT

// WARNING: This smart contract is for testing and educational purposes only.
// DO NOT USE in production environments as it may contain vulnerabilities

pragma solidity 0.8.26;

contract ICRRegistry {
    error ICR__IsNotOwner(address _notOwner);
    error ICR__InvalidCar(uint256 _carId);
    error ICR__CarIsNotInTheCorrectStatus(uint256 _carId, Status _status);
    error ICR__IsNotMc(uint256 _carId, address _notMc);

    error ICR__NotEnoughEther(uint256 _price);
    error ICR__PriceIsTooSmall(uint256 _price);
    error ICR__PriceIsTooBig(uint256 _price);

    event CarRegistered(uint256 _carId, address _mc);

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

    uint256 private constant LOWER_PRICE_LIMIT = 0.1 ether; // 0.1 ether = 10^17 wei​
    uint256 private constant UPPER_PRICE_LIMIT = 10 ether; // 10 ether = 10 * 10^18 wei
    address internal immutable owner;

    mapping(uint256 _carId => Car _car) internal cars;
    uint256 private nextCarId;

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
        emit CarRegistered(currentCarId, _mc);
    }

    function getNextCarId() external view returns (uint256) {
        return nextCarId;
    }

    function getCar(uint256 _carId) external view returns (Car memory) {
        return cars[_carId];
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getLowerPriceLimit() public pure returns (uint256) {
        return LOWER_PRICE_LIMIT;
    }

    function getUpperPriceLimit() public pure returns (uint256) {
        return UPPER_PRICE_LIMIT;
    }

    modifier carIsValid(uint256 _carId) {
        if (_carId >= nextCarId) {
            revert ICR__InvalidCar(_carId);
        }
        _;
    }
}

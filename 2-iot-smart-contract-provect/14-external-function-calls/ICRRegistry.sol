// SPDX-License-Identifier: MIT

// WARNING: This smart contract is for testing and educational purposes only.
// DO NOT USE in production environments as it may contain vulnerabilities

pragma solidity 0.8.26;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ICRRegistry is ReentrancyGuard {
    error ICR__IsNotOwner(address _notOwner);
    error ICR__InvalidCar(uint256 _carId);
    error ICR__CarIsNotInTheCorrectStatus(uint256 _carId, Status _status);
    error ICR__IsNotMc(uint256 _carId, address _notMc);

    error ICR__NotEnoughEther(uint256 _price);
    error ICR__PriceIsTooSmall(uint256 _price);
    error ICR__PriceIsTooBig(uint256 _price);

    error ICR__WithdrawFailed();
    error ICR__RentingTimeIsNotOverYet(uint256 _time, uint256 _carId);

    error ICR__McIsAlreadyUsed(address _mc);

    error ICR__CarRentingIsPaused();

    error ICR__IsNotFactory(address _notFactory);

    event CarRegistered(uint256 _carId, address _mc);
    event PauseChanged(bool _paused);

    enum Status {
        UNAVAILABLE,
        AVAILABLE,
        OCCUPIED
    }

    struct Car {
        address mc;
        uint256 price;
        Status status;
        uint256 timeOfLastRent;
    }

    uint256 private constant LOWER_PRICE_LIMIT = 0.1 ether; // 0.1 ether = 10^17 wei​
    uint256 private constant UPPER_PRICE_LIMIT = 10 ether; // 10 ether = 10 * 10^18 wei

    uint256 internal constant RENT_TIME = 1 days;

    address internal immutable i_owner;
    address private immutable i_factory;

    mapping(uint256 _carId => Car _car) internal s_cars;
    uint256 private s_nextCarId;

    mapping(address _mc => bool _used) private s_mcIsUsed;

    bool internal s_paused;

    constructor(address _owner) {
        require(_owner != address(0), "address 0 cannot be the owner");
        i_owner = _owner;
        i_factory = msg.sender;
    }

    function registerCar(address _mc, uint256 _price) public nonReentrant {
        if (msg.sender != i_factory) {
            revert ICR__IsNotFactory(msg.sender);
        }
        if (_price < LOWER_PRICE_LIMIT) {
            revert ICR__PriceIsTooSmall(_price);
        }
        if (_price > UPPER_PRICE_LIMIT) {
            revert ICR__PriceIsTooBig(_price);
        }
        if (s_mcIsUsed[_mc]) {
            revert ICR__McIsAlreadyUsed(_mc);
        }
        s_mcIsUsed[_mc] = true;
        Car memory car = Car(_mc, _price, Status.UNAVAILABLE, 0);
        uint256 currentCarId = s_nextCarId;
        s_cars[currentCarId] = car;
        s_nextCarId++;
        emit CarRegistered(currentCarId, _mc);
    }

    function withdraw() external nonReentrant {
        if (msg.sender != i_owner) {
            revert ICR__IsNotOwner(msg.sender);
        }
        // call
        (bool callSuccess,) = payable(i_owner).call{value: address(this).balance}("");
        if (!callSuccess) {
            revert ICR__WithdrawFailed();
        }
    }

    function ChangePause() public nonReentrant {
        if (msg.sender != i_owner) {
            revert ICR__IsNotOwner(msg.sender);
        }
        if (s_paused) {
            s_paused = false;
        } else {
            s_paused = true;
        }
        emit PauseChanged(s_paused);
    }

    function getNextCarId() external view returns (uint256) {
        return s_nextCarId;
    }

    function getCar(uint256 _carId) external view returns (Car memory) {
        return s_cars[_carId];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getLowerPriceLimit() public pure returns (uint256) {
        return LOWER_PRICE_LIMIT;
    }

    function getUpperPriceLimit() public pure returns (uint256) {
        return UPPER_PRICE_LIMIT;
    }

    modifier carIsValid(uint256 _carId) {
        if (_carId >= s_nextCarId) {
            revert ICR__InvalidCar(_carId);
        }
        _;
    }

    modifier isPaused() {
        if (s_paused) {
            revert ICR__CarRentingIsPaused();
        }
        _;
    }
}

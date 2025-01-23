//SPDX-License-Identifier: MIT

// WARNING: This smart contract is for testing and educational purposes only.
// DO NOT USE in production environments as it may contain vulnerabilities

pragma solidity 0.8.26;

contract SimpleStorage {
    event NumberSet(uint256 indexed _storedNumber);

    uint256 storedNumber;

    function setNumber(uint256 _storedNumber) public {
        storedNumber = _storedNumber;
        emit NumberSet(storedNumber);
    }

    function getNumber() public view returns (uint256) {
        return storedNumber;
    }
}

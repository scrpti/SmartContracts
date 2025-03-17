// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract SimpleStorage {
    uint storedData = 1;

    function set(uint x) public {
        storedData = multiply(storedData, x);
    }

    function get() public view returns (uint) {
        return storedData;
    }

    function multiply(uint x, uint y) public pure returns (uint){
        return x * y;
    }

    function multiply(uint x) public view returns (uint){
        return multiply(x, storedData);
    }
}
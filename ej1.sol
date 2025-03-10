// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract SimpleStorage {
    uint storedData;

    function set(uint x) public {
        uint y = get();
        storedData = x + y;
    }

    function combinePure(uint x, uint y) public pure returns (uint) {
        return x * y;
    }

    function combineView(uint x) public {
        uint y = get();
        storedData = x + y;
    }

    function get() public view returns (uint) {
        return storedData;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract SimpleStorage {
    uint storedData;
    //Infinite gas
    function set(uint x) public {
        uint y = get();
        storedData = x + y;
    }
    //Infinite gas
    function combinePure(uint x, uint y) public pure returns (uint) {
        return x * y;
    }
    //Infinite gas
    function combineView(uint x) public {
        uint y = get();
        storedData = x + y;
    }
    //2432 gas
    function get() public view returns (uint) {
        return storedData;
    }
}

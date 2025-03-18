// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract SimpleStorage {
    uint storedData = 1;

    function set(uint x) public { //Gasto grande porque modifica el estado
        storedData = multiply(storedData, x);
    }

    function get() public view returns (uint) {
        return storedData;
    }

    function multiply(uint x, uint y) public pure returns (uint){ //Gasto irrisorio porque ni lee ni modifica
        require(y != 0, "Division por cero");
        require(x <= type(uint).max / y, "Desbordamiento");
        return x * y;
    }

    function multiply(uint x) public view returns (uint){ //Gasto medio porque lee pero no modifica
        return multiply(x, storedData);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract SimpleStorage {
    uint storedData;
    mapping(address => uint) storedDataMap;
    
    constructor (){
        storedDataMap[msg.sender] = 1;
    }

    function set(uint x) public { //Gasto grande porque modifica el estado

        storedDataMap[msg.sender] = multiply(storedData, x);
    }

    function get() public view returns (uint) {
        return storedDataMap[msg.sender];
    }

    function multiply(uint x, uint y) public pure returns (uint){ //Gasto irrisorio porque ni lee ni modifica
        require(y != 0, "Division por cero");
        require(x <= type(uint).max / y, "Desbordamiento");
        return x * y;
    }

    function multiply(uint x) public view returns (uint){ //Gasto medio porque lee pero no modifica
        return multiply(x, storedData);
    }

    function setX(uint8 x) public pure returns (uint8) { //Gasta 24895
        return x;
    } 

    function setX(uint16 x) public pure returns (uint16) { //Gasta 24811
        return x;
    } 

    function setX(uint256 x) public pure returns (uint256) { //Gasta 22559
        return x;
    } 

    // Esto pasa porque la EVM de Ethereum tiene palabras de 32 bytes entonces es mejor almacenar datos de 32 bytes que de 8 o 16 bytes
    

    // Lectura de valores
    function getSmall() public pure returns (uint8) { //Gasta 416
        uint8 smallValue = 1; 
        return smallValue;
    }

    function getMedium() public pure returns (uint16) { //Gasta 445
        uint8 mediumValue = 1; 
        return mediumValue;
    }

    function getLarge() public pure returns (uint256) { //Gasta 373
        uint8 largeValue = 1; 
        return largeValue;
    }

    // Con las funciones de get pasa lo mismo
}
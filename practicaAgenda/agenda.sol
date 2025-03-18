// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract Agenda {
    //Ejercicio 1//
    struct User {
        address userAddress;
        string name;
    }

    struct ReadAccess {
        address userWithAccess;
        uint256 expiry;
    }

    mapping (address => User[]) agenda;
    mapping (address => ReadAccess[]) access;

    //Ejercicio 1//

    //Ejercicio 2//
    function addContact(address _address, string memory _name) public {
        agenda[msg.sender].push(User(_address, _name));
    }
    //Ejercicio 2//

    //Ejercicio 3//
    function getContact() external view returns (User[] memory) {
        return agenda[msg.sender];
    }

    //Editar un contacto por dirección o nombre
    function editContact(address _address, string memory _name) external {
        bool found = false;
        address usuario = msg.sender;
        for (uint i = 0; i < agenda[usuario].length && !found; ++i) {
            //Buscamos si hay alguna dirección que coincida con la dirección pasada, en este caso actualizamos el nombre
            if (agenda[usuario][i].userAddress == _address) {
                found = true;
                agenda[usuario][i].name = _name;
            }
            //Buscamos si hay algun nombre que coincida con el nombre pasado, en este caso actualizamos la dirección
            else if (keccak256(abi.encodePacked(agenda[usuario][i].name)) == keccak256(abi.encodePacked(_name))){
                found = true;
                agenda[usuario][i].userAddress = _address;
            }
            //Si no coincide ninguno de los dos parametros pasados, 
            require(found, "No se encontro la direccion o nombre");
        }
    }

    //Eliminar un contacto por direccion
    function deleteContactByAddress(address _address) external {
        bool found = false;
        address usuario = msg.sender;
        for (uint i = 0; i < agenda[usuario].length && !found ; ++i){
            if(agenda[usuario][i].userAddress == _address) {
                found = true;
                agenda[usuario][i] = agenda[usuario][agenda[usuario].length - 1];
                agenda[usuario].pop();
            } else require(found, "No se encontro la direccion");
        }
    }

    //Eliminar un contacto por direccion
    function deleteContactByName(string memory _name) external {
        bool found = false;
        address usuario = msg.sender;
        for (uint i = 0; i < agenda[usuario].length && !found ; ++i){
            if(keccak256(abi.encodePacked(agenda[usuario][i].name)) == keccak256(abi.encodePacked(_name))) {
                found = true;
                agenda[usuario][i] = agenda[usuario][agenda[usuario].length - 1];
                agenda[usuario].pop();
            } else require(found, "No se encontro la direccion o nombre");
        }
    }

    //Ejercicio 3//

    //Ejercicio 4//

    function giveReadAccess(address addressWithAccess, uint256 expiry) external{
        access[msg.sender].push(ReadAccess(addressWithAccess, block.timestamp + expiry));
    }

    function readAgendaWithAccess(address owner) external view returns (User[] memory){
        for(uint256 i = 0; i < access[owner].length ; ++i){
            if(access[owner][i].userWithAccess == msg.sender && block.timestamp <= access[owner][i].expiry){
                return agenda[owner];
            }
        }
        revert("No tiene permiso para ver esta agenda");
    }

    //Ejercicio 4//

    //Ejercicio 5//

    function getUserByAddress(address _address) external view returns (string memory name){
        address usuario = msg.sender;
        bool found = false;
        for(uint256 i = 0; i < agenda[usuario].length && !found; ++i){
            if(agenda[usuario][i].userAddress == _address){
                return agenda[usuario][i].name;
            }
        } 
        if(!found){
            revert("Usuario no encontrado");
        }
    }

    function getUserByAddress(string memory _name) external view returns (address direccion){
        address usuario = msg.sender;
        bool found = false;
        for(uint256 i = 0; i < agenda[usuario].length ; ++i){
            if(keccak256(abi.encodePacked(agenda[usuario][i].name)) == keccak256(abi.encodePacked(_name))){
                return agenda[usuario][i].userAddress;
            }
        } 
        if(!found){
            revert("Usuario no encontrado");
        }
    }

    //Ejercicio 5//

}
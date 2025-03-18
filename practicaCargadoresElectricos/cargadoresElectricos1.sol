// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.1 <0.9.0;

contract cargadoresElectricos {
    event ChargingSessionEvent (address user, uint256 startTime, uint256 duration, uint256 id);

    struct ChargingSession{
        address user;    //El usuario que usa el cargador
        uint256 startTime;  //Tiempo de uso
        uint256 duration;   //Duracion
    }

    mapping (uint256 => ChargingSession) log; //El mapping sera con el id del cargador y la sesion de carga 
    uint256 nChargers;
    uint256 costPerMinute;
    address owner;
    uint256 minTime = 0;
    uint256 maxTime = 7200;

    constructor (uint256 _n, uint256 _cpm) {
        require(_n <= 32, "La cantidad de cargadores maxima es 32");
        nChargers = _n; //Numero de cargadores
        costPerMinute = _cpm; //Coste por minuto p.e. 80 => 80 wei / minuto
        owner = msg.sender; //El owner es quien despliega el contrato
    }  

    function chargeVehicle(uint256 _time, uint256 id) external {
        require(id > 0 || id <= nChargers, "ID no valido");
        require(log[id].user == address(0) || log[id].startTime + log[id].duration < block.timestamp, "Cargador en uso"); //Comprueba que el cargador no este en uso
        require(_time >= minTime, "El tiempo de carga es menor que 10min");
        require(_time <= maxTime, "El tiempo de carga es mayor que 2 horas");
        log[id] = ChargingSession(msg.sender, block.timestamp, _time);
        emit ChargingSessionEvent(msg.sender, block.timestamp, _time, id);
    }

}
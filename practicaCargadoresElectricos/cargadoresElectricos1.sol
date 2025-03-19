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
    uint256 cAvailable;
    uint256 costPerMinute;
    address owner;
    uint256 minTime = 0;
    uint256 maxTime = 7200;

    constructor (uint256 _n, uint256 _cpm) {
        require(_n <= 32, "La cantidad de cargadores maxima es 32");
        nChargers = _n; //Numero de cargadores
        cAvailable = _n; //Numero de cargadores
        costPerMinute = _cpm; //Coste por minuto p.e. 80 => 80 wei / minuto
        owner = msg.sender; //El owner es quien despliega el contrato
    }  

    //En este metodo el usuario propone un cargador para cargar su vehiculo, pero hay un problema y es que si la persona propone un cargador en uso pierde
    //el dinero de haber preguntado por el cargador

    function chargeVehicle(uint256 _time, uint256 id) external { 
        require(id > 0 || id <= nChargers, "ID no valido");
        require(log[id].user == address(0) || log[id].startTime + log[id].duration < block.timestamp, "Cargador en uso"); //Comprueba que el cargador no este en uso
        require(_time >= minTime, "El tiempo de carga es menor que 10min");
        require(_time <= maxTime, "El tiempo de carga es mayor que 2 horas");
        log[id] = ChargingSession(msg.sender, block.timestamp, _time);
        emit ChargingSessionEvent(msg.sender, block.timestamp, _time, id);
    }

    //En este metodo el sistema, eficientemente, asigna un cargador que tiene constancia de que no se esta usando, por lo que el usuario no pierde dinero

    function chargeVehicleEfficient(uint256 _time) external payable{

        //------------------------------------
        //               CHECKS
        //------------------------------------
        //Comprobamos si esta el value 
        require(msg.value >= _time * costPerMinute, "Debes pagar el coste de cargar");
        //Comprobamos si hay cargadores
        require(checkAvailability(nChargers, cAvailable) == 0, "No hay cargadores disponibles");
        //Comprobamos que el tiempo de carga sea valido
        require(_time >= minTime, "El tiempo de carga es menor que 10min");
        require(_time <= maxTime, "El tiempo de carga es mayor que 2 horas");

        //------------------------------------
        //              EFFECTS
        //------------------------------------

        //Buscamos un cargador disponible
        uint256 id = findChargerAvailable(nChargers, cAvailable);
        //Asignamos el cargador
        log[id] = ChargingSession(msg.sender, block.timestamp, _time);
        //Emitimos el evento
        emit ChargingSessionEvent(msg.sender, block.timestamp, _time, id);
        //Decrementamos el numero de cargadores disponibles
        cAvailable--;
    }


    //Setter de log[i]
    function emptyLogI(uint256 index) public {
        log[index] = ChargingSession(address(0), 0, 0);
    }

    //El sistema también debe disponer de un administrador que sea capaz de vaciar la caja del contrato cuando le interese, solo él debe ser capaz de retirar esos fondos.

    function redeemProfit() external {
        require(msg.sender == owner, "Solo el owner puede retirar los fondos");
        payable(owner).transfer(address(this).balance);
    }

    //Frontend

    //Esta función busca los cargadores disponibles, recorriendo los indices mirando si tienen alguna dirección asignada

    function findChargerAvailable(uint256 nChargers, uint256 cAvailable) public view returns (uint256) {
        for (uint256 i = 0; i < nChargers ; ++i){
            ChargingSession memory session = viewLog(i);
            if(session.user == address(0)){
                return i;
            }
        }
    }

    //Esta función actualiza las sesiones, en caso de que ya se haya pasado su tiempo se elimina la sesión del mapping de sesiones 

    function checkAvailability(uint256 nChargers, uint256 cAvailable) public returns (uint256) {
        for (uint256 i = 0; i < nChargers ; ++i){
            ChargingSession memory session = viewLog(i);
            if(session.user != address(0) && (session.startTime + session.duration) < block.timestamp){
                emptyLogI(i);
                cAvailable++;
            }
        }
    }

    //Views

    function viewLog(uint256 index) public view returns (ChargingSession memory){ 
        return log[index];
    }

}
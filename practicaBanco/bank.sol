// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract Bank {


    mapping (address => uint256) balances;
    mapping (address => uint256) deudas;
    mapping (address => uint256) timestampDeudas;

    uint256 coefCaja = 5;
    uint256 interesPrestamos = 1; //1% diario
    uint256 plazoPrestamo = 7 days;

    //Al desplegar el contrato, el dueño del contrato se define como owner para posteriormente obtener recompensas por los intereses de los prestamos
    constructor() payable {
        owner = msg.sender;
    }

    //Cualquiera puede hacer un depósito de ETH, que queda asociado a su cuenta.

    function deposit() external payable {
        address sender = msg.sender;
        uint256 amountDeposit = msg.value;
        balances[sender] += amountDeposit; //depositar ETH
    }

    //En cualquier momento se puede retirar un depósito.

    function withdraw(uint256 _amount) external {
        address sender = msg.sender;
        uint256 vault = uint256(address(this).balance) * uint256((100-coefCaja) / 100);
        require (_amount <= balances[sender] && _amount <= vault, "No se pudo realizar el retiro por falta de fondos");//si el valor a retirar es mayor al saldo de la cuenta, no se puede realizar
        balances[sender] -= _amount; //retirar ETH
        payable(msg.sender).transfer(_amount);//enviar ETH
    }

    //Ofrecer un método para consultar el saldo propio el banco.

    function getVaultBalance() external view returns (uint256){
        return address(this).balance;
    }

    //El banco puede realizar préstamos con el dinero que tiene en depósito.

    function getLoan(uint256 _amount) external {
        //El prestatario puede pedir una deuda como mucho el 50% de su balance, teniendo en cuenta que si la cantidad de su intento de prestamo mas su deuda 
        //supera este 50% se le deniega la prestación

        //Comprobacion de candidato para un prestamo
        bool isEligibleForLoan = (deudas[msg.sender] + _amount) <= ((balances[msg.sender] * 50) / 100);
        require(isEligibleForLoan, "Su cantidad de prestamo no puede superar el 50% de su balance");

        //Comprobación de coefCaja válido
        require(coefCaja < 100, "Coeficiente de caja debe ser menor a 100");
        address sender = msg.sender;
        uint256 vault = (address(this).balance * (100 - coefCaja)) / 100;

        //Comprobación de fondos suficientes
        require(_amount <= vault, "No se pudo realizar el prestamo por falta de fondos");
        deudas[sender] += _amount;
        timestampDeudas[sender] = block.timestamp;

        //Envío de dinero
        payable(sender).transfer(_amount);
    }

    //Ofrecer un método para consultar el saldo deudor de cualquier cuenta.

    function getLoanBalance(address _account) external view returns (uint256){
        return deudas[_account] + getInteres(_account);
    }

    //Los préstamos del banco puede tener asociado un tipo de interés conocido. Sería interesante que la
    //deuda fuera creciendo debido a los intereses conforme pasa el tiempo.

    function getInteres(address _account) public view returns (uint256) {
        uint256 timeElapsed = (block.timestamp - timestampDeudas[_account]) / 1 days; //Obtenemos el tiempo transcurrido en dias de la deuda
        uint256 interes = 0;
        //Idear algún mecanismo para que no se identifique a los prestatarios directamente como "deudores".
        //Por ejemplo, se les puede dar un plazo para que devuelvan el préstamo, y si expira, ya se les incluye
        //en la lista de "deudores"
        if(timeElapsed >= plazoPrestamo && deudas[_account] > 1){
            interes = (deudas[_account] * (timeElapsed * interesPrestamos)) / 100;
        }
        return interes;

    }

    function payLoan() external payable{
        uint256 totalDebt = deudas[msg.sender] + getInteres(msg.sender);
        uint256 profit = getInteres(msg.sender); 
        uint256 amount = msg.value;
        require(amount >= totalDebt, "El pago de la deuda no puede ser menor al total de la deuda");

        deudas[msg.sender] = 0;
        timestampDeudas[msg.sender] = 0;

        //Sería más interesante aún que los beneficios generados por estos préstamos con interés fueran a
        //parar al que creó el contrato

        payable(owner).transfer(profit);
    }


}


// 1 ETH = 100000000000000000 wei
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract Bank {

    uint256 vault = address(this).balance;

    mapping (address => uint256) balances;
    mapping (address => uint256) deudas;

    int256 coefCaja = 5;
    int256 interesBanco = 10;

    constructor() payable {

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
        address sender = msg.sender;
        int256 vault = int256(address(this).balance) * ((100-coefCaja) / 100);
            require(_amount <= vault, "No se pudo realizar el prestamo por falta de fondos");
        deudas[sender] += _amount;
        payable(sender).transfer(_amount);
    }

    //Ofrecer un método para consultar el saldo deudor de cualquier cuenta.

    function getLoanBalance(address _account) external view returns (uint256){
        return deudas[_account];
    }

    //Los préstamos del banco puede tener asociado un tipo de interés conocido. Sería interesante que la
    //deuda fuera creciendo debido a los intereses conforme pasa el tiempo.

    function getInteres(address _account) internal view returns (uint256){
        uint256 interes = (deudas[_account] * interesPrestamos) / 100;
        return interes;
    }

    function payLoan() external payable{
        uint256 totalDebt = deudas[msg.sender] + getInteres(msg.sender);
        uint256 amount = msg.value;
        require(amount >= totalDebt, "El pago de la deuda no puede ser menor al total de la deuda");

    }


}


// 1 ETH = 100000000000000000 wei
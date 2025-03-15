// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract Donate {
    mapping(address => uint256) public donations;
    address payable public ownerAddress;

    constructor() {
        ownerAddress = payable(msg.sender); // Asigna la dirección del deployer como owner
    }

    function donate() external payable {
        require(msg.value > 0, "Debe enviar algo de ETH");
        donations[msg.sender] += msg.value;
    }

    function getDonationsValue() external view returns (uint256) {
        return address(this).balance;
    }

    function withdrawDonations(uint256 _amount) external {
        require(msg.sender == ownerAddress, "Solo el owner puede retirar");
        require(_amount <= address(this).balance, "Fondos insuficientes");

        (bool success, ) = ownerAddress.call{value: _amount}("");
        require(success, "Transferencia fallida");
    }
}

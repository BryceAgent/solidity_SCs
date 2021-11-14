// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9;

contract Faucet {
    event Withdrawal(address indexed to, uint amount);
    event Deposit(address indexed from, uint amount);
    address owner;
    address payable recipient;
    enum State {Open, Closed}
    State status;
    
    
    constructor() {
        owner = msg.sender;
        status = State.Open;
    }
    
    // give ether to whoever asks
    function withdraw(uint _withdraw) public {
        // check faucet status
        require(status == State.Open, "Faucet is closed");
        // limit withdrawal amount
        require(_withdraw <= .01 * 10 ** 18);
        // check faucet balance
        require(address(this).balance >= _withdraw, "Insufficient balance in faucet for withdrawal request");
        // send the amount to address making request
        recipient = payable(msg.sender);
        recipient.transfer(_withdraw);
        emit Withdrawal(msg.sender, _withdraw);
    }
    
    // accept incoming payments
    receive () external payable {
        emit Deposit(msg.sender, msg.value);
    }
    
    // close the faucet
    function close(string memory _pass) public {
        require(msg.sender == owner);
    //    require(keccak256(_pass) == 'password hash'); password could only be used once! after that not secure
        if(status == State.Open) {
            status = State.Closed;
        }
    }
    
    // open the faucet
    function open(string memory _pass) public {
        require(msg.sender == owner);
    //    require(keccak256(_pass) == 'password hash');
        if(status == State.Closed) {
            status = State.Open;
        }
    }
}

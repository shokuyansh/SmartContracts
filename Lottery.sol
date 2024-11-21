// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Lottery{
    address public owner;
    address winner;
    bool LotteryStarted=false;
    constructor() {
        owner = msg.sender;
    }
    uint public registeredNum; 
    address[]  registered;
    modifier onlyOwner(){
        require(owner==msg.sender,"Not the owner!");
        _;
    }
    modifier isRunning{
        require(LotteryStarted==true,"Not started yet!");
        _;
    }
    function buyTicket() public payable{
        require(msg.value==2 ether,"Insufficient amount");
        registered.push(msg.sender); 
        registeredNum++;
    }
    function startLottery() external onlyOwner {
        require(registeredNum>2,"Not enough people yet!");
        LotteryStarted=true;

    }
    function endLottery() external onlyOwner(){
       registered = new address[](0);
    }
    event winnerEvent(address _winner, uint value);
    function getWinner() public isRunning onlyOwner {
        require (winner==address(0));  //ensure the winner is not set yet
        uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % registeredNum;  //random number between 0 and 19
        winner=registered[randomNumber];
        emit winnerEvent(winner,address(this).balance);
        bool result = payable (winner).send(address(this).balance);
        require(result,"Not able to send the balance");
        
    }
    function getBalance() external view returns(uint){
        return address(this).balance;
    }   
}
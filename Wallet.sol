//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract wallet{
    struct Transaction{
        address fromAddress;
        address toAddress;
        uint transTime;
        uint value;   
    }
    Transaction[] public TransactionHistory;
    address owner;
    mapping (address =>uint) suspiciousUser;
    constructor(){
        owner=msg.sender;
    }
    event Transfer(address to,uint value);
    event Recieve(address from,uint value);
    event userRecieve(address from,address to,uint value);
    bool stop;
    modifier onlyowner {
        require(owner==msg.sender,"NOT THE OWNER");
        _;
    }
    modifier suspicious(address _sender){
        require(suspiciousUser[_sender]<5,"try again!");
        _;
    }
    function toggleStop() external onlyowner{
        stop=!stop;
    }
    modifier isEmergencyDeclared{
        require(stop==false,"Emergency declared");
        _;
    }
    function changeOwner(address _newowner) public onlyowner isEmergencyDeclared{
        require(_newowner!=owner,"New owner has to be different");
        owner=_newowner;
    }
    function transferFromUserToContract() public suspicious(msg.sender) payable{
        TransactionHistory.push(Transaction(msg.sender,address(this),block.timestamp,msg.value));
    }
    function balanceofContract() public view returns(uint){
        return address(this).balance;
    }
     function transferToUserfromContract(address payable _to,uint _weiAmount) public {
        require(address(this).balance>=_weiAmount,"Insufficient fund in contract");
        require(_to!=address(0),"Address not correct");
        _to.transfer(_weiAmount);
        TransactionHistory.push(Transaction(owner,_to,block.timestamp,_weiAmount));
        emit Transfer(_to, _weiAmount);
    }
    function WithdrawFromContract(uint _weiAmount) public onlyowner{
        require(address(this).balance>=_weiAmount,"Insufficient funds");
        TransactionHistory.push(Transaction(address(this),owner,block.timestamp,_weiAmount));
        payable(owner).transfer(_weiAmount);
    }
    // User related functions
    function transferTouserViaMsgValue(address _to) public payable onlyowner{
        require(address(this).balance>=msg.value,"Paisa nhi hai lawde");
        require(_to!=address(0),"Address not correct");
        TransactionHistory.push(Transaction(msg.sender,_to,block.timestamp,msg.value));
        payable(_to).transfer(msg.value);
        

    }
    function receiveFromUser() external payable {
        require(msg.value>=0,"ye garib!");
        payable(owner).transfer(msg.value);
        TransactionHistory.push(Transaction(msg.sender,owner,block.timestamp,msg.value));

        emit userRecieve(msg.sender,owner,msg.value);
    }
    function getOwnerBalanceInWei() external  view returns(uint){
        return (owner.balance);
    }
    function emergencyWithdrawl() external {
        require(stop==true,"emergency not declared");
        payable(owner).transfer(address(this).balance); 
    }

    receive() external payable {
        emit Recieve(msg.sender, msg.value);
        TransactionHistory.push(Transaction(msg.sender,address(this),block.timestamp,msg.value));

     }
    event suspiciouslogs(address sender,uint blocktime);
    function getsuspicioususer(address _sender) public {
        suspiciousUser[_sender]++;
        if(suspiciousUser[_sender]>=5){
          removeban(_sender);
    }}
    function removeban(address _sender) public {
             emit suspiciouslogs(_sender, block.timestamp); 
            if (suspiciousUser[_sender] >= 5) {
                suspiciousUser[_sender] = 0; 
    }
    }
    fallback() external  payable{
        getsuspicioususer(msg.sender);
     }

    function getTransactionHistory() external view returns(Transaction[] memory){
        return TransactionHistory;
    }
}

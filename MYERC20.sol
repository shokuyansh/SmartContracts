// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract demo {
    string name="MyToken";
    string symbol="MTK";
    uint decimals=18;
    uint256 public totalSupply;
    address founder;
    constructor(){
        founder=msg.sender;
        totalSupply=1000000*(10**uint256(decimals));
        balance[founder]=totalSupply;
    }
    mapping (address=>uint256) balance;
    mapping(address=>mapping (address=>uint256)) allowedTokens;
    bool pauseTransfer;
    modifier pauseAll{
        require(pauseTransfer!=true,"PAUSE IN EFFECT");
        _;
    }
   event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);  
    function balanceOf(address account) external view returns (uint256){
        return balance[account];
    }
    function transfer(address to, uint256 value) external pauseAll returns (bool){
        require(to!=address(0),"invalid address");
        require(balance[msg.sender]>value,"invalid balance");
        require(freezed[to]!=false,"ACCOUNT FREEZED");       
        balance[msg.sender]-=value;
        balance[to]+=value;
        emit Transfer(msg.sender,to,value);
        return true;
    }
    function allowance(address owner, address spender) external view returns (uint256){
        require(spender!=address(0),"invalid address");
        require(owner!=address(0),"invalid address");
        return allowedTokens[owner][spender];
    }
    function approve(address spender, uint256 value) external returns (bool){
        require(spender!=address(0),"invalid address");
        require(balance[msg.sender]>value,"invalid balance");
        balance[msg.sender]-=value;
        allowedTokens[founder][spender]+=value;
        emit Approval(founder, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) external pauseAll returns (bool){
        require(to!=address(0),"invalid address");
        require(from!=address(0),"invalid address");
        require(balance[from]>value,"invalid balance");
        require(freezed[from]!=false,"ACCOUNT FREEZED");
        require(freezed[to]!=false,"ACCOUNT FREEZED");   

        balance[from]-=value;
        balance[to]+=value;
        return true;
    }
    function mint(address to,uint256 amount) external {
        require(to!=address(0),"Invalid address");
        require(msg.sender==founder);
        balance[to]+=amount;
        totalSupply+=amount;
    }
    function burn(uint256 amount) external{
        require(amount>0,"can't burn nothing");
        balance[msg.sender]-=amount;
        totalSupply-=amount;
    }
    mapping(address=>bool) freezed;
    
    function freezeAccount(address account) external{
        require(msg.sender==founder);
        freezed[account]=true;
    }
    function unfreezeAccount(address account) external{
        require(msg.sender==founder); 
        freezed[account]=false;
    }
    
    function pause() external{
        require(msg.sender==founder);
        pauseTransfer=true;
    }
    function unpause() external{
        require(msg.sender==founder);
        pauseTransfer=false;
    }
    mapping (address=>bool) lockedAccounts;
    function blacklist(address account) external{
        require(msg.sender==founder);
       lockedAccounts[account]=true;
    }
    function unblacklist(address account) external{
        require(msg.sender==founder);
       lockedAccounts[account]=false;
    }
    function transferOwnership(address newOwner) external{
        require(msg.sender==founder);
        founder=newOwner;
    }
}
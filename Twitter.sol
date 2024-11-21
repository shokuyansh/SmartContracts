// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19 ;

contract TwitterContract{
    struct Tweet{
        uint ID;
        address  author;
        string content;
        uint createdAt;
    }
    struct Message{
        uint ID;
        string content;
        address sender;
        address reciever;
        uint createdAt;
    }
    mapping (uint =>Tweet) private  tweets;
    mapping (address=>uint[]) private tweetsof;
    mapping (uint=>Message[]) private conversations;
    mapping (address=>mapping(address => bool)) private operators;
    mapping (address => address[]) private following;

    uint nextId;
    uint nextMessageId;

    function _tweet(address _from , string memory _content) internal 
    {   
        tweets[nextId]=Tweet(nextId,_from,_content,block.timestamp);
        tweetsof[_from].push(nextId);
        nextId++;
        
    }
    function _sendmessage(address _from,address _to,string memory _content) internal {  
        conversations[nextMessageId].push(Message(nextMessageId,_content,_from,_to,block.timestamp));
        nextMessageId++;
    }
    function tweet(string memory _content) public returns(address){

            _tweet(msg.sender,_content);
            return msg.sender;
    }
    function tweet(address _from,string memory _content) public returns(address){
        require(_from==msg.sender||operators[_from][msg.sender]==true,"NOT ALLOWED");   
        _tweet(_from,_content);
        return msg.sender;
    }

    function sendMessage(address _to,string memory _content) public{
        _sendmessage(msg.sender,_to,_content);
    }
    function sendMessage(address _from,address _to,string memory _content) public{
        require(_from==msg.sender||operators[msg.sender][_from]==true,"NOT ALLOWED");
        _sendmessage(_from,_to,_content);
    }

    function follow(address _followed) public {
        following[msg.sender].push(_followed);
    }

    function allow(address _operator) public{
        operators[msg.sender][_operator]=true;
    }

    function disallow(address _operator) public{
        operators[msg.sender][_operator]=false;
    }
    function getLatestTweets(uint count)public view returns(Tweet[] memory){//you cannot return mappings from inside function
        require(count>0 && count<=nextId,"Count is not proper");
        Tweet[] memory _tweets=new Tweet[](count);//array length=count

        uint j;
        for(uint i=nextId-count;i<nextId;i++){
            Tweet storage _structure=tweets[i];
            _tweets[j]=Tweet(_structure.ID,_structure.author,_structure.content,_structure.createdAt);
            j=j+1;
        }
            return _tweets;
    }
    function getLatestofUser(address _user,uint count) public view returns(Tweet[] memory){
        
        Tweet[] memory usertweet=new Tweet[](count);
        uint[] storage tweetsid=tweetsof[_user];
        require(count>0&&count<=tweetsid.length,"COunt is not proper");
        uint j;
        for(uint i=tweetsof[_user].length-count;i<tweetsof[_user].length;i++)
        {   //uint num=tweet
            Tweet storage _structure=tweets[tweetsid[i]];
            usertweet[j]=_structure;
            j++;
            
        }
        return usertweet;
    }

}
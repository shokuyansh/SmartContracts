// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract EventOrganisation {
    struct Event{
        string name;
        address organiser;
        uint date;
        uint totaltickets;
        uint ticketRemaining;
        uint price;
    }
    mapping(uint=>Event) public events;
    mapping(address => mapping(uint => uint)) public Ticket;
    uint public nextID;
    mapping(uint => bool) startEvent;
    mapping (uint => address) public owners;
    
    function createEvent(string memory _name, address _organiser ,uint _date, uint _totaltickets,uint _price) public {
            require(bytes(_name).length!= 0,"Name cannot be empty!");
            require(_organiser!=address(0)," Enter a valid Address!");
            require(_totaltickets >= 0," Enter a valid number of tickets!");
            require(_price>=0,"Price cannot be zero");
            require(_date>block.timestamp,"Date can't be set in past!");
            events[nextID] = Event(
                _name,
                 _organiser,
                 _date,
                 _totaltickets,
                 _totaltickets,
                _price
            );
            owners[nextID] = _organiser;
            nextID++;
            
    }
    function buyTicket(uint num , uint event_id) external  payable {
        require(startEvent[event_id]==true,"Event not started");
        require(events[event_id].date!=0,"Event does not exist");
        require(events[event_id].date>block.timestamp,"Cant buy ticket for a past event");
        require(num>=0,"Enter a valid number of tickets!");
        require(msg.sender!=address(0),"Enter a valid address.");
        
        Event storage _event = events[event_id];
        require(msg.value>(num*_event.price),"Not enough amount");
        require(_event.ticketRemaining>num,"Not enough tickets remaining for this event");
        

        _event.ticketRemaining  = _event.ticketRemaining - num ;
        Ticket[msg.sender][event_id] += num;
    }
    function StartEvent(uint _eventID,address _address) external  {
        require(_address!=address(0),"Valid address");
        require(owners[_eventID]==_address,"Not the owner of this event!");
        require(!startEvent[_eventID], "You have already started this event!");
        startEvent[_eventID] = true;
    }
    function TransferTicket(uint _eventID, uint num , address _to) external {
        require(_to != msg.sender,"Enter a valid receiver!");
        require(events[_eventID].date!=0,"Event does not exist");
        require(events[_eventID].date>block.timestamp,"Cant buy ticket for a past event");
        require(Ticket[msg.sender][_eventID]>=num,"Not enough tickets!");
        Ticket[msg.sender][_eventID] -= num;
        Ticket[_to][_eventID]+= num;
    }
    function calculateTicketPrice(uint _eventID,uint num) external view returns(uint){
            return num*events[_eventID].price;
    }
     
 
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Lottery_Contract {
    address public owner;
    bool public started;
    bool public ended;
    uint public endAt;
    address public winnerAddress;
    
    struct ParticipantStruct {
        string name;
        uint phoneNumber;
        address walletAddress;
    }

    address payable [] public participants_Address;
    mapping (address => ParticipantStruct) public participants_Details;


    constructor () {
        owner = msg.sender;
    }

    modifier OnlyOwner {
        require(msg.sender == owner, "Only owner can call this function!");
        _;
    }

    /*-----------Get-Balance-----------*/
    function getBalance () public view returns(uint) {
        return address(this).balance;
    }

    /*-----------Get-Participants-----------*/
    function getParticipants () public view returns(address payable [] memory) {
        return participants_Address;
    }

    /*-----------Start-Lottery-----------*/
    function startLottery () public OnlyOwner {
        require(!started, "Lottery already started!");
        
        started = true;
        endAt = block.timestamp + 7 days;
    }

    /*-----------Enter-Lottery-----------*/
    function enter (string memory _name, uint _phoneNumber) public payable {
        require(started == true, "Lottery should be started first before you enter!");
        require(!ended, "Lottery has already ended!");
        require(msg.value >= .01 ether, "You need atleast .01 ether to enter the lottery");
        
        participants_Address.push(payable(msg.sender));
        participants_Details[msg.sender] = ParticipantStruct(_name, _phoneNumber, msg.sender);
    }

    /*-----------End-Lottery-----------*/
    function end () public {
        require(started, "Lottery should be started first before it ends!");
        require(!ended, "Lottery already ended!");
        require(block.timestamp > endAt, "Lottery is still ongoing");

        ended = true;
    }
    
    /*-----------Get-Random-Number-----------*/
    function getRandomNumber () public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
    }


    /*-----------Pick-Winner-----------*/
    function pickWinner () public OnlyOwner {
        require(ended, "Lottery should be ended in order to determine the winner!");
        uint index = getRandomNumber() % participants_Address.length;
        
        winnerAddress = participants_Address[index];
        (bool isSent, ) = participants_Address[index].call{value: address(this).balance}("");
        require(isSent, "Transfering Failled!");

        participants_Address = new address payable [](0);        
    }

    /*-----------Get-Winner-Info-----------*/
    function getWinnerInfo (address _addr) public view returns (ParticipantStruct memory) {
        return participants_Details[_addr];
    }
}


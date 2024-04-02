//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

contract Election{
    struct Candidate{
        string name;
        uint numOfVotes;
        string id;
        string candidatePos;
        }
    struct Voter{
        string matricNum;
        bool hasVoted;
        string uniqueId;
        }

    address public owner;
    string public electionName;
    Candidate[] public candidatesList;
    Voter[] private  votersList;
    uint public totalVotes;

    modifier ownerOnly(){
        require(msg.sender==owner);
        _;
    }

    function getVotersList()ownerOnly public view returns(Voter[] memory){return votersList;}
    function getCandidatesList()ownerOnly public view returns(Candidate[] memory){return candidatesList;}

    function startElection(string memory _electionName) public {
        owner=msg.sender;
        electionName=_electionName;
        }

    function random(uint256 number,uint256 counter)private view returns (uint256){ 
        return uint256(keccak256(abi.encodePacked(block.timestamp,block.basefee,msg.sender,counter)))%number;
    }
    function randomIdGenerator()private view returns (string memory){ 
        bytes memory randomIdGen= new bytes(10);
        bytes memory characters= new bytes(62);
        characters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        for (uint256 i=0; i < 10; i++) 
        {
            uint256 randomNumber=random(62,i);
            randomIdGen[i]=characters[randomNumber];
        }
        return string(randomIdGen);
    }

    function addCandidate(string memory _candidateName,string memory _candidateId,string memory _candidatePos)ownerOnly public {
        candidatesList.push(Candidate(_candidateName,0,_candidateId,_candidatePos));
    }

    function addVoter(string memory _matricNum)ownerOnly public returns (string memory){
       string memory _uniqueId=randomIdGenerator();
        votersList.push(Voter(_matricNum,false,_uniqueId));
        return _uniqueId;
    }

    function authoriseVoter(string memory _matricNum, string memory _uniqueId)ownerOnly public view returns (bool){
        bool isAuthorised=false;
        for (uint i=0; i<votersList.length; i++) 
        {
            if (keccak256(abi.encodePacked(votersList[i].matricNum))==keccak256(abi.encodePacked(_matricNum))
            &&keccak256(abi.encodePacked(votersList[i].uniqueId))==keccak256(abi.encodePacked(_uniqueId))) {
                isAuthorised=true;

            }
        }

        return isAuthorised;
    }

    function vote(string memory _matricNum,string[] memory _idList)ownerOnly public returns (string memory){
        bool eligible=false;
        string memory _message="Vote uncompleted";
        for (uint a=0; a<votersList.length; a++) 
        {
           if (keccak256(abi.encodePacked(votersList[a].matricNum))==keccak256(abi.encodePacked(_matricNum))) {
            eligible=!votersList[a].hasVoted;
            votersList[a].hasVoted=true;
           }
        }
        
      if (eligible){ for (uint i=0; i<_idList.length; i++) 
        {
            for (uint j=0; j<candidatesList.length; j++) 
            {
                if (keccak256(abi.encodePacked(_idList[i]))==keccak256(abi.encodePacked(candidatesList[j].id))) {
                    candidatesList[j].numOfVotes++;
                    totalVotes++;
                    _message= "Vote completed";
                }
            }
        }
        }return _message;
    }
}

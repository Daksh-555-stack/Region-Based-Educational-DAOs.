// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RegionBasedEducationalDAO is Ownable {
    struct Proposal {
        uint256 id;
        string title;
        string description;
        uint256 voteCount;
        address proposer;
        bool executed;
    }

    struct Member {
        bool isMember;
        uint256 votes; // Number of votes the member has
    }

    mapping(address => Member) public members;
    mapping(uint256 => Proposal) public proposals;

    uint256 public proposalCount;

    event MemberAdded(address member);
    event ProposalCreated(uint256 id, string title, address proposer);
    event Voted(uint256 proposalId, address voter);
    event ProposalExecuted(uint256 proposalId);

    modifier onlyMember() {
        require(members[msg.sender].isMember, "Not a DAO member");
        _;
    }

    constructor() Ownable(msg.sender) {
        // Initialize DAO
    }

    // Add a member to the DAO
    function addMember(address _member) public onlyOwner {
        require(!members[_member].isMember, "Already a member");
        members[_member] = Member({isMember: true, votes: 1});
        emit MemberAdded(_member);
    }

    // Create a new proposal
    function createProposal(string memory _title, string memory _description)
        public
        onlyMember
    {
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            title: _title,
            description: _description,
            voteCount: 0,
            proposer: msg.sender,
            executed: false
        });
        emit ProposalCreated(proposalCount, _title, msg.sender);
        proposalCount++;
    }

    // Vote for a proposal
    function vote(uint256 _proposalId) public onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(members[msg.sender].votes > 0, "No votes left");

        members[msg.sender].votes--;
        proposal.voteCount++;

        emit Voted(_proposalId, msg.sender);
    }

    // Execute a proposal
    function executeProposal(uint256 _proposalId) public onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.voteCount > 0, "Not enough votes to execute");

        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
    }
}

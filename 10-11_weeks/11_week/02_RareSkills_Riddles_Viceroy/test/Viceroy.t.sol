// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {GovernanceViceroyAssigner} from "../src/Attack.sol";
import {OligarchyNFT, Governance} from "../src/Viceroy.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract GatekeeperOneTest is Test {
    GovernanceViceroyAssigner governanceViceroyAssigner;
    OligarchyNFT oligarchyNFT;
    Governance governanace;
    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address user3 = vm.addr(3);

    function setUp() public {
        vm.deal(user1, 50 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 50 ether);
        
        vm.startPrank(user1);
        governanceViceroyAssigner = new GovernanceViceroyAssigner(user2);
        oligarchyNFT = new OligarchyNFT(address(governanceViceroyAssigner));
        governanace = new Governance{value: 50 ether}(ERC721(oligarchyNFT));
    }

    function test_deleteuser() public {
        assertEq(user2.balance, 100 ether);
        
        governanceViceroyAssigner.attack(address(governanace));
        
        assertEq(user2.balance, 150 ether);
    }
}

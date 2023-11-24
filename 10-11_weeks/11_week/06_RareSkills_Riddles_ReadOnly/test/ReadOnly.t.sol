// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {VulnerableDeFiContract, ReadOnlyPool, Exploit} from "../src/ReadOnly.sol";

contract RewardTokenTest is Test {
    ReadOnlyPool readOnlyPool;
    VulnerableDeFiContract vulnerableDeFiContract;
    Exploit exploit;
    
    address user1 = vm.addr(1);

    function setUp() public {
        vm.deal(user1, 10000 ether);
        vm.startPrank(user1);

        readOnlyPool = new ReadOnlyPool();
        readOnlyPool.addLiquidity{value: 100 ether}();

        vulnerableDeFiContract = new VulnerableDeFiContract(readOnlyPool);
        vulnerableDeFiContract.snapshotPrice();
    }

    function test_exploit() public {
        
        assert(vulnerableDeFiContract.lpTokenPrice() == 1) ;
        assert(readOnlyPool.getVirtualPrice() == 1) ;
        
        exploit = new Exploit{value: 50 ether}(vulnerableDeFiContract, readOnlyPool);
        assert(vulnerableDeFiContract.lpTokenPrice() == 1) ;
        assert(readOnlyPool.getVirtualPrice() == 1);

        exploit.exploit();

        assert(vulnerableDeFiContract.lpTokenPrice() == 0) ;
    }
}

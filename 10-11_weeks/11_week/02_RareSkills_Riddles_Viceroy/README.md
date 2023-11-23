# RareSkills Riddles - Viceroy

This one was tough. 
Goal is to take all money from CommunityWallet. 

In order to achieve that we need to have 10 votes on our proposal. 

Steps for exploit

- register our attacker contract as viceroy, viceroy will be contract in our case (and only EOA are allowed) so we need to calculate cntract address prior deployment, when code length is 0
- create proposal which is executing `CommunityWallet.exec` method and send funds to provided address
- in order to achieve this we need to have 10 votes 
- we will achieve 10 votes by doing `approveVoter` -> `vote` -> `disapproveVoter`. We need to do it like this because we can only have 5 voters at same time. 
- voters will be contracts so we need to do similar as in registering viceroy
- once we have 10 voters approved we will `executeProposal` and send all the monet to provided treasury address

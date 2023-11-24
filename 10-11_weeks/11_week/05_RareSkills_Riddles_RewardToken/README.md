# 05 RareSkills Riddles - RewardToken

This is classic reentrancy issue when executing `withdrawAndClaimEarnings` method. State is updated after external contract hook call.
Then in `onERC721Received` we just claim rest of rewards token left in depositor.

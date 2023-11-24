# 05 RareSkills Riddles - ReadOnly

At first it seems that `lpTokenPrice` from `VulnerableDeFiContract` will be always bigger or equalt to 1, as value is get from taking snapshot and snapshot is calculates by  `address(pool).balance / totalSupply();` As LP tokens are minted by same amount of adde liquidity ETH, this value can not be less than 1, but during `removeLiquidity` call we can upon receiving ETH in our attacker contract manipulate defi snapshot price before LP tokens are bur, which will cause price to be 0.

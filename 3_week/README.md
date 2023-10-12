# Math behind - Uniswap V2

## SWAP

![Swap](images/1_SWAP.png)


## ADD LIQUIDITIY

![Add Liquidity](images/2_ADD_LIQUIDITY.png)


## ADD LIQUIDITIY - MINT

![Add Liquidity - Mint](images/3_ADD_LIQUIDITY_MINT.png)


## REMOVE LIQUIDITIY - BURN

![Add Liquidity - Mint](images/4_REMOVE_LIQUIDITY_BURN.png)

## PROTOCOL FEE
1/6th of Liquidity provider fees. Instead of calculating it on each swap it is calculated only on `mint` or `burn` 
on accumulated fees.  

![Protocol Fee](images/5_UNISWAP_PROTOCOL_FEE.png)
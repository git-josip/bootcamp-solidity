# ERC721A

The ERC721A implementation was created by Azuki, and its main purpose is to allow for gas-efficient minting of multiple NFTs in one transaction. With this implementation, users will save on gas fees over the long run if they are minting more than one token at a time. 

The gas cost to mint NFTs increases by:
* ~2k gas per extra mint using the Azuki ERC721A contract
* ~115k gas per extra mint using the OpenZeppelin ERC721Enumerable contract

For the price of minting one single token via the ERC721Enumerable contract, a user can instead mint up to 5 tokens (or more, potentially) via the ERC721A contract.

## How does ERC721A save gas?

1. Removing duplicate storage from OpenZeppelin’s (OZ) ERC721Enumerable
2. Updating the owner’s balance once per batch mint request, instead of per minted NFT
3. Updating the owner data once per batch mint request, instead of per minted NFT

## Where does it add costs?

The tradeoff of the ERC721A contract design is that transferFrom and safeTransferFrom transactions cost more gas, which means it may cost more to gift or sell an ERC721A NFT after minting.

The ERC721A _safeMint logic makes efficiency gains by not setting explicit owners of specific tokenIDs when they are consecutive IDs minted by the same owner.

ERC721A contract was that it indeed keeps the cost low for batch mints, but it has that nasty loop in _ownershipOf and it calls _ownershipOf each time a token transfer happens.

Let’s imagine an unrealistic scenario in which we mint 350 tokens in a single transaction, then check the ownership of token id 330 and transfer it. (The getOwner function is a simple function that calls ownerOf and then write something to storage, to illustrate the costs of any write functions calling ownerOf). Goas cost will be ~900k.

## Why shouldn’t ERC721A enumerable’s implementation be used on-chain?

ERC721Enumerable uses a crazy amount of redundant storage, which drives up the costs of not only minting tokens but also transferring them.
ERC721 Enumerable should not be used on-chain as gas cost is to high for minting NFTs, esecially is user can mint multiple NFTs. Cost becomes higher as there are number of minhted NFTs increases as there are to many complex structres to update, where token <> owner is tracked so later it can be easily used on frontend client.

Using ERC721A is also problematic whet it comes to transfering ownership. If we do not limit number of tokens to some reasonable number per user, let's say 10-15 prices go up. And if we do not have limt loop in ownership method spikes.


References: 

- https://www.alchemy.com/blog/erc721-vs-erc721a-batch-minting-nfts
- https://medium.com/coinmonks/comparison-of-the-most-popular-erc721-templates-b3614353e31e
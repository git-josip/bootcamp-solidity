# OpenSea track NFT

They run indexers software that “listen” to every single block that got mined, looking for events that represent erc20/721 token transfers, and then update an ownership table for fast queries.
Events are tracked for contracts listed on Opensea.

To retrieve every transaction that has happened with a smart contract, the Ethereum client would have to scan every block, which would be an extremely heavy I/O operation; but Ethereum uses an important optimization.

Events are stored in a Bloom Filter data structure for each block. A Bloom Filter is a probabilistic set that efficiently answers if a member is in the set or not. Instead of scanning the entire block, the client can ask the bloom filter if an event was emitted in the block; it's far faster to query a bloom filter than to scan the entire block.





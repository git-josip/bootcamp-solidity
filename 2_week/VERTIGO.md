# Vertigo - mutation testing

Run vertigo: 
In project root folder where is foundry initialized. 

```
 python vertigo.py run
```

## Vertigo result

[*] Starting mutation testing
[*] Starting analysis on project
[+] Foundry project detected
[+] If this is taking a while, vertigo-rs is probably installing dependencies in your project
[*] Initializing campaign run 
[*] Checking validity of project
[+] The project is valid
[*] Storing compilation results
[*] Running analysis on 99 mutants
  1%|█▍                                                                                                                                        | 1/99 [00:02<03:23,  2.08s/mutant]WARNING:root:Error: 
  2%|██▊                                                                                                                                       | 2/99 [00:02<02:13,  1.37s/mutant]WARNING:root:Error: 
  3%|████▏                                                                                                                                     | 3/99 [00:03<01:50,  1.15s/mutant]WARNING:root:Error: 

[*] Done with campaign run
[+] Report:
Mutation testing report:
Number of mutations:    99
Killed:                 56 / 99

Mutations:

[+] Survivors
Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/3_NftNumerable.sol
    Line nr: 27
    Result: Lived
    Original line:
                 require(tokenId - 1 < MAX_SUPPLY, "All tokes are minted.");

    Mutated line:
                 require(tokenId - 1 <= MAX_SUPPLY, "All tokes are minted.");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/3_NftNumerable.sol
    Line nr: 18
    Result: Lived
    Original line:
             constructor(string memory _name, string memory _symbol) Ownable() ERC721(_name, _symbol) {}

    Mutated line:
             constructor(string memory _name, string memory _symbol)  ERC721(_name, _symbol) {}

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/3_NftNumerable.sol
    Line nr: 37
    Result: Lived
    Original line:
             function withdrawEther() external onlyOwner {

    Mutated line:
             function withdrawEther() external  {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/2_NftStakingToken.sol
    Line nr: 29
    Result: Lived
    Original line:
                 require(tokenId < maxSupply, "All tokes are minted.");

    Mutated line:
                 require(tokenId <= maxSupply, "All tokes are minted.");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/2_NftStakingToken.sol
    Line nr: 32
    Result: Lived
    Original line:
                     currentTokenId = tokenId + 1;

    Mutated line:
                     currentTokenId = tokenId - 1;

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/2_NftStakingToken.sol
    Line nr: 18
    Result: Lived
    Original line:
             constructor(string memory _name, string memory _symbol, uint256 _maxSupply) Ownable() ERC721(_name, _symbol) {

    Mutated line:
             constructor(string memory _name, string memory _symbol, uint256 _maxSupply)  ERC721(_name, _symbol) {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/2_NftStakingToken.sol
    Line nr: 39
    Result: Lived
    Original line:
             function withdrawEther() external onlyOwner {

    Mutated line:
             function withdrawEther() external  {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/2_StakeAndGetReward.sol
    Line nr: 74
    Result: Lived
    Original line:
                 if (rewardAmount > 0) {

    Mutated line:
                 if (rewardAmount >= 0) {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/2_StakeAndGetReward.sol
    Line nr: 93
    Result: Lived
    Original line:
                 if (rewardAmount > 0) {

    Mutated line:
                 if (rewardAmount >= 0) {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/2_StakeAndGetReward.sol
    Line nr: 125
    Result: Lived
    Original line:
                 require(nftDeposit.stakedAt > 0, "TokenId is not staked with this contract.");

    Mutated line:
                 require(nftDeposit.stakedAt >= 0, "TokenId is not staked with this contract.");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/2_StakeAndGetReward.sol
    Line nr: 152
    Result: Lived
    Original line:
                 return interfaceId == type(IERC721Receiver).interfaceId || super.supportsInterface(interfaceId);

    Mutated line:
                 return interfaceId == interfaceId || super.supportsInterface(interfaceId);

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/2_StakeAndGetReward.sol
    Line nr: 36
    Result: Lived
    Original line:
             constructor(IERC721 _nftStakeTokenContract) Ownable() {

    Mutated line:
             constructor(IERC721 _nftStakeTokenContract)  {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/2_StakeAndGetReward.sol
    Line nr: 136
    Result: Lived
    Original line:
             function setRewardTokenContract(IRewardToken _rewardTokenContract) external onlyOwner {

    Mutated line:
             function setRewardTokenContract(IRewardToken _rewardTokenContract) external  {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/1_NftWithMerkleAndRoyalties.sol
    Line nr: 34
    Result: Lived
    Original line:
                 require(_maxSupply > 0, "MaxSupply must be bigger than 0");

    Mutated line:
                 require(_maxSupply >= 0, "MaxSupply must be bigger than 0");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/1_NftWithMerkleAndRoyalties.sol
    Line nr: 93
    Result: Lived
    Original line:
                     currentTokenId = tokenId + 1;

    Mutated line:
                     currentTokenId = tokenId - 1;

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/2_RewardToken.sol
    Line nr: 47
    Result: Lived
    Original line:
                 require(_amount > 0, "Amount to mint needs to be bigger than 0.");

    Mutated line:
                 require(_amount >= 0, "Amount to mint needs to be bigger than 0.");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/2_week/src/2_RewardToken.sol
    Line nr: 47
    Result: Lived
    Original line:
                 require(_amount > 0, "Amount to mint needs to be bigger than 0.");

    Mutated line:
                 require(_amount >= 0, "Amount to mint needs to be bigger than 0.");

[*] Done! 
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
[*] Running analysis on 87 mutants
  9%|████████████▋                                                                                                                             | 8/87 [00:16<02:42,  2.06s/mutant]WARNING:root:Error: 
 22%|█████████████████████████████▉                                                                                                           | 19/87 [00:44<03:12,  2.83s/mutant]WARNING:root:Error: 
 71%|█████████████████████████████████████████████████████████████████████████████████████████████████▋                                       | 62/87 [02:20<00:55,  2.21s/mutant]WARNING:root:Error: 
 93%|███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████▌         | 81/87 [03:00<00:12,  2.15s/mutant]WARNING:root:Error: 
100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 87/87 [03:12<00:00,  2.21s/mutant]
[*] Done with campaign run
[+] Report:
Mutation testing report:
Number of mutations:    87
Killed:                 53 / 87

Mutations:

[+] Survivors
Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/1_TokenWIthSanctions.sol
    Line nr: 23
    Result: Lived
    Original line:
                 require(_initialSupply > 0, "_initialSupply must be bigger than 0");

    Mutated line:
                 require(_initialSupply >= 0, "_initialSupply must be bigger than 0");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/1_TokenWIthSanctions.sol
    Line nr: 22
    Result: Lived
    Original line:
             constructor(string memory _name, string memory _symbol, uint256 _initialSupply) ERC20(_name, _symbol) Ownable() {

    Mutated line:
             constructor(string memory _name, string memory _symbol, uint256 _initialSupply) ERC20(_name, _symbol)  {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/1_TokenWIthSanctions.sol
    Line nr: 33
    Result: Lived
    Original line:
             function addSanctionForAddress(address _address) external onlyOwner {

    Mutated line:
             function addSanctionForAddress(address _address) external  {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/1_TokenWIthSanctions.sol
    Line nr: 46
    Result: Lived
    Original line:
             function removeSanctionForAddress(address _address) external onlyOwner {

    Mutated line:
             function removeSanctionForAddress(address _address) external  {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/2_TokenWIthGodMode.sol
    Line nr: 20
    Result: Lived
    Original line:
                 require(_initialSupply > 0, "_initialSupply must be bigger than 0");

    Mutated line:
                 require(_initialSupply >= 0, "_initialSupply must be bigger than 0");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/2_TokenWIthGodMode.sol
    Line nr: 19
    Result: Lived
    Original line:
             constructor(string memory _name, string memory _symbol, uint256 _initialSupply) ERC20(_name, _symbol) Ownable() {

    Mutated line:
             constructor(string memory _name, string memory _symbol, uint256 _initialSupply) ERC20(_name, _symbol)  {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/2_TokenWIthGodMode.sol
    Line nr: 38
    Result: Lived
    Original line:
             function setGodModeAddress(address _address) external onlyOwner {

    Mutated line:
             function setGodModeAddress(address _address) external  {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/2_TokenWIthGodMode.sol
    Line nr: 48
    Result: Lived
    Original line:
             function resetGodModeAddress() external onlyOwner {

    Mutated line:
             function resetGodModeAddress() external  {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/3_LinearBondingCurve.sol
    Line nr: 28
    Result: Lived
    Original line:
                 require(_baseTokenPriceInWei > 0, "_baseTokenPrice must be greater than zero");

    Mutated line:
                 require(_baseTokenPriceInWei >= 0, "_baseTokenPrice must be greater than zero");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/3_LinearBondingCurve.sol
    Line nr: 40
    Result: Lived
    Original line:
                 require(_tokenAmount > 0, "Amount must be greater than zero");

    Mutated line:
                 require(_tokenAmount >= 0, "Amount must be greater than zero");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/3_LinearBondingCurve.sol
    Line nr: 56
    Result: Lived
    Original line:
                 require(_tokenAmount > 0, "Amount must be greater than zero");

    Mutated line:
                 require(_tokenAmount >= 0, "Amount must be greater than zero");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/3_LinearBondingCurve.sol
    Line nr: 74
    Result: Lived
    Original line:
                 require(_tokenAmount > 0, "Amount must be greater than zero");

    Mutated line:
                 require(_tokenAmount >= 0, "Amount must be greater than zero");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/3_LinearBondingCurve.sol
    Line nr: 90
    Result: Lived
    Original line:
                 require(_tokenAmount > 0, "Amount must be greater than zero");

    Mutated line:
                 require(_tokenAmount >= 0, "Amount must be greater than zero");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/3_LinearBondingCurve.sol
    Line nr: 142
    Result: Lived
    Original line:
                 return interfaceId == type(IERC1363Receiver).interfaceId || super.supportsInterface(interfaceId);

    Mutated line:
                 return interfaceId != type(IERC1363Receiver).interfaceId || super.supportsInterface(interfaceId);

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/3_LinearBondingCurve.sol
    Line nr: 142
    Result: Lived
    Original line:
                 return interfaceId == type(IERC1363Receiver).interfaceId || super.supportsInterface(interfaceId);

    Mutated line:
                 return interfaceId != type(IERC1363Receiver).interfaceId || super.supportsInterface(interfaceId);

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/3_LinearBondingCurve.sol
    Line nr: 142
    Result: Lived
    Original line:
                 return interfaceId == type(IERC1363Receiver).interfaceId || super.supportsInterface(interfaceId);

    Mutated line:
                 return interfaceId == interfaceId || super.supportsInterface(interfaceId);

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/3_LinearBondingCurve.sol
    Line nr: 39
    Result: Lived
    Original line:
             function buy(uint256 _tokenAmount) external payable nonReentrant {

    Mutated line:
             function buy(uint256 _tokenAmount) external payable  {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/3_LinearBondingCurve.sol
    Line nr: 55
    Result: Lived
    Original line:
             function sell(uint256 _tokenAmount) external nonReentrant returns (bool success) {

    Mutated line:
             function sell(uint256 _tokenAmount) external  returns (bool success) {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/4_EScrow.sol
    Line nr: 51
    Result: Lived
    Original line:
                 require(transaction.lockedUntil > 0 && transaction.lockedUntil < block.timestamp, "This escrow still locked");

    Mutated line:
                 require(transaction.lockedUntil >= 0 && transaction.lockedUntil < block.timestamp, "This escrow still locked");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/4_EScrow.sol
    Line nr: 51
    Result: Lived
    Original line:
                 require(transaction.lockedUntil > 0 && transaction.lockedUntil < block.timestamp, "This escrow still locked");

    Mutated line:
                 require(transaction.lockedUntil > 0 && transaction.lockedUntil <= block.timestamp, "This escrow still locked");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/4_EScrow.sol
    Line nr: 102
    Result: Lived
    Original line:
                 return interfaceId == type(IERC1363Receiver).interfaceId;

    Mutated line:
                 return interfaceId != type(IERC1363Receiver).interfaceId;

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/4_EScrow.sol
    Line nr: 109
    Result: Lived
    Original line:
                 require(token.balanceOf(address(this)) > 0, "EScrow does not have any balance on this token.");

    Mutated line:
                 require(token.balanceOf(address(this)) >= 0, "EScrow does not have any balance on this token.");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/4_EScrow.sol
    Line nr: 102
    Result: Lived
    Original line:
                 return interfaceId == type(IERC1363Receiver).interfaceId;

    Mutated line:
                 return interfaceId != type(IERC1363Receiver).interfaceId;

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/4_EScrow.sol
    Line nr: 109
    Result: Lived
    Original line:
                 require(token.balanceOf(address(this)) > 0, "EScrow does not have any balance on this token.");

    Mutated line:
                 require(token.balanceOf(address(this)) <= 0, "EScrow does not have any balance on this token.");

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/4_EScrow.sol
    Line nr: 54
    Result: Lived
    Original line:
                 assert(transaction.token.balanceOf(address(this)) >= transaction.amount);

    Mutated line:
                 

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/4_EScrow.sol
    Line nr: 102
    Result: Lived
    Original line:
                 return interfaceId == type(IERC1363Receiver).interfaceId;

    Mutated line:
                 return interfaceId == interfaceId;

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/4_EScrow.sol
    Line nr: 37
    Result: Lived
    Original line:
             constructor(string memory _name) ReentrancyGuard() {

    Mutated line:
             constructor(string memory _name)  {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/4_EScrow.sol
    Line nr: 47
    Result: Lived
    Original line:
             function withdraw(uint256 _tx_id) external nonReentrant returns (bool) {

    Mutated line:
             function withdraw(uint256 _tx_id) external  returns (bool) {

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/4_EScrow.sol
    Line nr: 73
    Result: Lived
    Original line:
                 nonReentrant

    Mutated line:
                 

Mutation:
    File: /Users/mozzer/development/blockchain/mozzer-rareskills-solidity-bootcamp/1_week/src/4_EScrow.sol
    Line nr: 108
    Result: Lived
    Original line:
             function emergencyWithdrawToken(IERC20 token) external onlyOwner {

    Mutated line:
             function emergencyWithdrawToken(IERC20 token) external  {
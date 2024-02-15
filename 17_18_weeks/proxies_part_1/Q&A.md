### 1. The OZ upgrade tool for hardhat defends against 6 kinds of mistakes. What are they and why do they matter?

1. `Initialize`: In Solidity, code that is inside a constructor or part of a global variable declaration is not part of a deployed contract’s runtime bytecode. This code is executed only once, when the contract instance is deployed. As a consequence of this, the code within a logic contract’s constructor will never be executed in the context of the proxy’s state.  When using a contract with the OpenZeppelin Upgrades, you need to change its constructor into a regular function, typically named initialize, where you run all the setup logic, while Solidity ensures that a constructor is called only once in the lifetime of a contract, a regular function can be called many times. To prevent a contract from being initialized multiple times, you need to add a check to ensure the initialize
2. usage of `selfdestruct` opcode and `delegatecall` opcode: If the direct call to the logic contract triggers a selfdestruct operation, then the logic contract will be destroyed, and all your contract instances will end up delegating all calls to an address without any code. This would effectively break all contract instances in your project. A similar effect can be achieved if the logic contract contains a delegatecall operation. If the contract can be made to delegatecall into a malicious contract that contains a selfdestruct, then the calling contract will be destroyed.
3. `Storage collisions` between implementation versions: OpenZeppelin Upgrades detects such collisions and warns the developer appropriately
4. `Unstructured storage proxies`: Instead of storing the _implementation address at the proxy’s first storage slot, it chooses a pseudo random slot instead. This slot is sufficiently random, that the probability of a logic contract declaring a variable at the same slot is negligible. `keccak256('eip1967.proxy.implementation')) - 1` position for implementation contract address. THis will be used for any special storage variable proxy may have. For not those are implementation, beacon and admin addresses. 
5. `Transparent proxies and function clashes` : A transparent proxy will decide which calls are delegated to the underlying logic contract based on the caller address (i.e., the msg.sender):
If the caller is the admin of the proxy (the address with rights to upgrade the proxy), then the proxy will not delegate any calls, and only answer any messages it understands.
If the caller is any other address, the proxy will always delegate a call, no matter if it matches one of the proxy’s functions.
6. `Upgrading` implementation contract mechanism. ??not sure about 6 one

### 2. What is a beacon proxy used for?
An alternative upgradeability mechanism is provided in Beacon. This pattern, popularized by Dharma, allows multiple proxies to be upgraded to a different implementation in a single transaction. In this pattern, the proxy contract doesn’t hold the implementation address in storage like UpgradeableProxy, but the address of a UpgradeableBeacon contract, which is where the implementation address is actually stored and retrieved from. The upgrade operations that change the implementation contract address are then sent to the beacon instead of to the proxy contract, and all proxies that follow that beacon are automatically upgraded.

### 3.  Why does the openzeppelin upgradeable tool insert something like uint256[50] private __gap; inside the contracts?

To prevent storage collision in situations when we have parent/child or in proxy situation, where implementation storage variables are used in proxy contract, a slot can be secured by setting __gap in advance. By leaving __gap, it is possible to secure a slot from slot 0 to slot 50 in advance.

### 4. What is the difference between initializing the proxy and initializing the implementation? Do you need to do both? When do they need to be done?
A modifier that defines a protected initializer function that can be invoked at most once. In its scope, onlyInitializing functions can be used to initialize parent contracts.
To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as possible by providing the encoded function call as the _data argument to ERC1967Proxy.constructor.

Deployed implementation does not need to be initialized, as only rubtime code is used from this address. Storage is in proxy contract and proxy contract needs to be initialized.
An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke the _disableInitializers function in the constructor to automatically lock it when it is deployed.

### 5. What is the use for the reinitializer? Provide a minimal example of proper use in Solidity
A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the contract hasn’t been initialized to a greater version before. In its scope, onlyInitializing functions can be used to initialize parent contracts.

A reinitializer may be used after the original initialization step. This is essential to configure modules that are added through upgrades and that require initialization.

When version is 1, this modifier is similar to initializer, except that functions marked with reinitializer cannot be nested. If one is invoked in the context of another, execution will revert.
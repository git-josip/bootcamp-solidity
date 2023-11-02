# Slither

Run command: 
```
docker run --platform=linux/amd64 --rm -it -v ./:/share trailofbits/eth-security-toolbox  -c 'solc-select install 0.8.21 && solc-select use  0.8.21 && cd /share && slither --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/ @payabletoken/=lib/erc1363-payable-token/"  src/3_LinearBondingCurve.sol'
```


## TokenWithSanctions
<span style="color:yellow">

ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) ignores return value by IERC1363Receiver(recipient).onTransferReceived(_msgSender(),sender,amount,data) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#120-131)
ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) ignores return value by IERC1363Spender(spender).onApprovalReceived(_msgSender(),amount,data) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#151-162)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
</span>

<span style="color:green">
TokenWithSanctions.constructor(string,string,uint256)._name (src/1_TokenWIthSanctions.sol#23) shadows:
        - ERC20._name (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#45) (state variable)
TokenWithSanctions.constructor(string,string,uint256)._symbol (src/1_TokenWIthSanctions.sol#23) shadows:
        - ERC20._symbol (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#46) (state variable)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#local-variable-shadowing

Ownable2Step.transferOwnership(address).newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#35) lacks a zero-check on :
                - _pendingOwner = newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#36)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation

Variable 'ERC1363._checkOnTransferReceived(address,address,uint256,bytes).retval (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#120)' in ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) potentially used before declaration: retval == IERC1363Receiver.onTransferReceived.selector (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#121)
Variable 'ERC1363._checkOnTransferReceived(address,address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#122)' in ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) potentially used before declaration: reason.length == 0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#123)
Variable 'ERC1363._checkOnTransferReceived(address,address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#122)' in ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) potentially used before declaration: revert(uint256,uint256)(32 + reason,mload(uint256)(reason)) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#128)
Variable 'ERC1363._checkOnApprovalReceived(address,uint256,bytes).retval (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#151)' in ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) potentially used before declaration: retval == IERC1363Spender.onApprovalReceived.selector (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#152)
Variable 'ERC1363._checkOnApprovalReceived(address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#153)' in ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) potentially used before declaration: reason.length == 0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#154)
Variable 'ERC1363._checkOnApprovalReceived(address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#153)' in ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) potentially used before declaration: revert(uint256,uint256)(32 + reason,mload(uint256)(reason)) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#159)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#pre-declaration-usage-of-local-variables

ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) uses assembly
        - INLINE ASM (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#127-129)
ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) uses assembly
        - INLINE ASM (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#158-160)
Address._revert(bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#231-243) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Address.sol#236-239)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage

TokenWithSanctions._beforeTokenTransfer(address,address,uint256) (src/1_TokenWIthSanctions.sol#67-72) compares to a boolean constant:
        -require(bool,string)(sanctionedAddresses[to] == false,Address to is sanctioned.) (src/1_TokenWIthSanctions.sol#71)
TokenWithSanctions._beforeTokenTransfer(address,address,uint256) (src/1_TokenWIthSanctions.sol#67-72) compares to a boolean constant:
        -require(bool,string)(sanctionedAddresses[from] == false,Address from is sanctioned.) (src/1_TokenWIthSanctions.sol#70)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#boolean-equality

Different versions of Solidity are used:
        - Version used: ['0.8.21', '^0.8.0', '^0.8.1']
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#3)
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363.sol#3)
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol#3)
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Spender.sol#3)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4)
        - ^0.8.1 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
        - 0.8.21 (src/1_TokenWIthSanctions.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used

Address._revert(bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#231-243) is never used and should be removed
Address.functionCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#89-91) is never used and should be removed
Address.functionCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#99-105) is never used and should be removed
Address.functionCallWithValue(address,bytes,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#118-120) is never used and should be removed
Address.functionCallWithValue(address,bytes,uint256,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#128-137) is never used and should be removed
Address.functionDelegateCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#170-172) is never used and should be removed
Address.functionDelegateCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#180-187) is never used and should be removed
Address.functionStaticCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#145-147) is never used and should be removed
Address.functionStaticCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#155-162) is never used and should be removed
Address.isContract(address) (lib/openzeppelin-contracts/contracts/utils/Address.sol#40-46) is never used and should be removed
Address.sendValue(address,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#64-69) is never used and should be removed
Address.verifyCallResult(bool,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#219-229) is never used and should be removed
Address.verifyCallResultFromTarget(address,bool,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#195-211) is never used and should be removed
Context._msgData() (lib/openzeppelin-contracts/contracts/utils/Context.sol#21-23) is never used and should be removed
ERC20._burn(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#277-293) is never used and should be removed
SafeERC20._callOptionalReturn(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#117-124) is never used and should be removed
SafeERC20._callOptionalReturnBool(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#134-142) is never used and should be removed
SafeERC20.forceApprove(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#82-89) is never used and should be removed
SafeERC20.safeApprove(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#45-54) is never used and should be removed
SafeERC20.safeDecreaseAllowance(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#69-75) is never used and should be removed
SafeERC20.safeIncreaseAllowance(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#60-63) is never used and should be removed
SafeERC20.safePermit(IERC20Permit,address,address,uint256,uint256,uint8,bytes32,bytes32) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#95-109) is never used and should be removed
SafeERC20.safeTransfer(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#26-28) is never used and should be removed
SafeERC20.safeTransferFrom(IERC20,address,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#34-36) is never used and should be removed
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dead-code

Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#3) allows old versions
Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363.sol#3) allows old versions
Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol#3) allows old versions
Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Spender.sol#3) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4) allows old versions
Pragma version^0.8.1 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4) allows old versions
Pragma version0.8.21 (src/1_TokenWIthSanctions.sol#2) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.7
solc-0.8.21 is not recommended for deployment
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity

Low level call in SafeERC20._callOptionalReturnBool(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#134-142):
        - (success,returndata) = address(token).call(data) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#139)
Low level call in Address.sendValue(address,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#64-69):
        - (success) = recipient.call{value: amount}() (lib/openzeppelin-contracts/contracts/utils/Address.sol#67)
Low level call in Address.functionCallWithValue(address,bytes,uint256,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#128-137):
        - (success,returndata) = target.call{value: value}(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#135)
Low level call in Address.functionStaticCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#155-162):
        - (success,returndata) = target.staticcall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#160)
Low level call in Address.functionDelegateCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#180-187):
        - (success,returndata) = target.delegatecall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#185)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls

Function IERC20Permit.DOMAIN_SEPARATOR() (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#59) is not in mixedCase
Parameter TokenWithSanctions.addSanctionForAddress(address)._address (src/1_TokenWIthSanctions.sol#34) is not in mixedCase
Parameter TokenWithSanctions.removeSanctionForAddress(address)._address (src/1_TokenWIthSanctions.sol#47) is not in mixedCase
Parameter TokenWithSanctions.isAddressSanctioned(address)._address (src/1_TokenWIthSanctions.sol#57) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions

transferAndCall(address,uint256) should be declared external:
        - ERC1363.transferAndCall(address,uint256) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#31-33)
transferFromAndCall(address,address,uint256) should be declared external:
        - ERC1363.transferFromAndCall(address,address,uint256) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#55-57)
approveAndCall(address,uint256) should be declared external:
        - ERC1363.approveAndCall(address,uint256) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#84-86)
renounceOwnership() should be declared external:
        - Ownable.renounceOwnership() (lib/openzeppelin-contracts/contracts/access/Ownable.sol#61-63)
transferOwnership(address) should be declared external:
        - Ownable.transferOwnership(address) (lib/openzeppelin-contracts/contracts/access/Ownable.sol#69-72)
        - Ownable2Step.transferOwnership(address) (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#35-38)
acceptOwnership() should be declared external:
        - Ownable2Step.acceptOwnership() (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#52-56)
name() should be declared external:
        - ERC20.name() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#62-64)
symbol() should be declared external:
        - ERC20.symbol() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#70-72)
decimals() should be declared external:
        - ERC20.decimals() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#87-89)
totalSupply() should be declared external:
        - ERC20.totalSupply() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#94-96)
balanceOf(address) should be declared external:
        - ERC20.balanceOf(address) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#101-103)
increaseAllowance(address,uint256) should be declared external:
        - ERC20.increaseAllowance(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#177-181)
decreaseAllowance(address,uint256) should be declared external:
        - ERC20.decreaseAllowance(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#197-206)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#public-function-that-could-be-declared-external
</span>

## TokenWIthGodMode
<span style="color:yellow">
ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) ignores return value by IERC1363Receiver(recipient).onTransferReceived(_msgSender(),sender,amount,data) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#120-131)
ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) ignores return value by IERC1363Spender(spender).onApprovalReceived(_msgSender(),amount,data) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#151-162)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
</span>

<span style="color:green">
TokenWIthGodMode.constructor(string,string,uint256)._name (src/2_TokenWIthGodMode.sol#20) shadows:
        - ERC20._name (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#45) (state variable)
TokenWIthGodMode.constructor(string,string,uint256)._symbol (src/2_TokenWIthGodMode.sol#20) shadows:
        - ERC20._symbol (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#46) (state variable)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#local-variable-shadowing

TokenWIthGodMode.setGodModeAddress(address) (src/2_TokenWIthGodMode.sol#39-43) should emit an event for: 
        - godModeAddress = _address (src/2_TokenWIthGodMode.sol#42) 
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-events-access-control

Ownable2Step.transferOwnership(address).newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#35) lacks a zero-check on :
                - _pendingOwner = newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#36)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation

Variable 'ERC1363._checkOnTransferReceived(address,address,uint256,bytes).retval (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#120)' in ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) potentially used before declaration: retval == IERC1363Receiver.onTransferReceived.selector (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#121)
Variable 'ERC1363._checkOnTransferReceived(address,address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#122)' in ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) potentially used before declaration: reason.length == 0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#123)
Variable 'ERC1363._checkOnTransferReceived(address,address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#122)' in ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) potentially used before declaration: revert(uint256,uint256)(32 + reason,mload(uint256)(reason)) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#128)
Variable 'ERC1363._checkOnApprovalReceived(address,uint256,bytes).retval (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#151)' in ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) potentially used before declaration: retval == IERC1363Spender.onApprovalReceived.selector (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#152)
Variable 'ERC1363._checkOnApprovalReceived(address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#153)' in ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) potentially used before declaration: reason.length == 0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#154)
Variable 'ERC1363._checkOnApprovalReceived(address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#153)' in ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) potentially used before declaration: revert(uint256,uint256)(32 + reason,mload(uint256)(reason)) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#159)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#pre-declaration-usage-of-local-variables

ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) uses assembly
        - INLINE ASM (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#127-129)
ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) uses assembly
        - INLINE ASM (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#158-160)
Address._revert(bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#231-243) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Address.sol#236-239)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage

Different versions of Solidity are used:
        - Version used: ['0.8.21', '^0.8.0', '^0.8.1']
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#3)
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363.sol#3)
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol#3)
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Spender.sol#3)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4)
        - ^0.8.1 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
        - 0.8.21 (src/2_TokenWIthGodMode.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used

Address._revert(bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#231-243) is never used and should be removed
Address.functionCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#89-91) is never used and should be removed
Address.functionCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#99-105) is never used and should be removed
Address.functionCallWithValue(address,bytes,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#118-120) is never used and should be removed
Address.functionCallWithValue(address,bytes,uint256,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#128-137) is never used and should be removed
Address.functionDelegateCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#170-172) is never used and should be removed
Address.functionDelegateCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#180-187) is never used and should be removed
Address.functionStaticCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#145-147) is never used and should be removed
Address.functionStaticCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#155-162) is never used and should be removed
Address.isContract(address) (lib/openzeppelin-contracts/contracts/utils/Address.sol#40-46) is never used and should be removed
Address.sendValue(address,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#64-69) is never used and should be removed
Address.verifyCallResult(bool,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#219-229) is never used and should be removed
Address.verifyCallResultFromTarget(address,bool,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#195-211) is never used and should be removed
Context._msgData() (lib/openzeppelin-contracts/contracts/utils/Context.sol#21-23) is never used and should be removed
ERC20._burn(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#277-293) is never used and should be removed
SafeERC20._callOptionalReturn(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#117-124) is never used and should be removed
SafeERC20._callOptionalReturnBool(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#134-142) is never used and should be removed
SafeERC20.forceApprove(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#82-89) is never used and should be removed
SafeERC20.safeApprove(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#45-54) is never used and should be removed
SafeERC20.safeDecreaseAllowance(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#69-75) is never used and should be removed
SafeERC20.safeIncreaseAllowance(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#60-63) is never used and should be removed
SafeERC20.safePermit(IERC20Permit,address,address,uint256,uint256,uint8,bytes32,bytes32) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#95-109) is never used and should be removed
SafeERC20.safeTransfer(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#26-28) is never used and should be removed
SafeERC20.safeTransferFrom(IERC20,address,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#34-36) is never used and should be removed
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dead-code

Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#3) allows old versions
Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363.sol#3) allows old versions
Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol#3) allows old versions
Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Spender.sol#3) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4) allows old versions
Pragma version^0.8.1 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4) allows old versions
Pragma version0.8.21 (src/2_TokenWIthGodMode.sol#2) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.7
solc-0.8.21 is not recommended for deployment
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity

Low level call in SafeERC20._callOptionalReturnBool(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#134-142):
        - (success,returndata) = address(token).call(data) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#139)
Low level call in Address.sendValue(address,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#64-69):
        - (success) = recipient.call{value: amount}() (lib/openzeppelin-contracts/contracts/utils/Address.sol#67)
Low level call in Address.functionCallWithValue(address,bytes,uint256,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#128-137):
        - (success,returndata) = target.call{value: value}(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#135)
Low level call in Address.functionStaticCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#155-162):
        - (success,returndata) = target.staticcall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#160)
Low level call in Address.functionDelegateCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#180-187):
        - (success,returndata) = target.delegatecall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#185)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls

Function IERC20Permit.DOMAIN_SEPARATOR() (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#59) is not in mixedCase
Parameter TokenWIthGodMode.setGodModeAddress(address)._address (src/2_TokenWIthGodMode.sol#39) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions

transferAndCall(address,uint256) should be declared external:
        - ERC1363.transferAndCall(address,uint256) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#31-33)
transferFromAndCall(address,address,uint256) should be declared external:
        - ERC1363.transferFromAndCall(address,address,uint256) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#55-57)
approveAndCall(address,uint256) should be declared external:
        - ERC1363.approveAndCall(address,uint256) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#84-86)
renounceOwnership() should be declared external:
        - Ownable.renounceOwnership() (lib/openzeppelin-contracts/contracts/access/Ownable.sol#61-63)
transferOwnership(address) should be declared external:
        - Ownable.transferOwnership(address) (lib/openzeppelin-contracts/contracts/access/Ownable.sol#69-72)
        - Ownable2Step.transferOwnership(address) (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#35-38)
acceptOwnership() should be declared external:
        - Ownable2Step.acceptOwnership() (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#52-56)
name() should be declared external:
        - ERC20.name() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#62-64)
symbol() should be declared external:
        - ERC20.symbol() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#70-72)
decimals() should be declared external:
        - ERC20.decimals() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#87-89)
totalSupply() should be declared external:
        - ERC20.totalSupply() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#94-96)
balanceOf(address) should be declared external:
        - ERC20.balanceOf(address) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#101-103)
increaseAllowance(address,uint256) should be declared external:
        - ERC20.increaseAllowance(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#177-181)
decreaseAllowance(address,uint256) should be declared external:
        - ERC20.decreaseAllowance(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#197-206)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#public-function-that-could-be-declared-external

</span>


## EScrow
<span style="color:red">
EScrow.withdraw(uint256) (src/4_EScrow.sol#48-64) ignores return value by transaction.token.transfer(transaction.seller,transaction.amount) (src/4_EScrow.sol#59)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unchecked-transfer

</span>

<span style="color:yellow">
ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) ignores return value by IERC1363Receiver(recipient).onTransferReceived(_msgSender(),sender,amount,data) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#120-131)
ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) ignores return value by IERC1363Spender(spender).onApprovalReceived(_msgSender(),amount,data) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#151-162)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
</span>

<span style="color:green">
Ownable2Step.transferOwnership(address).newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#35) lacks a zero-check on :
                - _pendingOwner = newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#36)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation

Variable 'ERC1363._checkOnTransferReceived(address,address,uint256,bytes).retval (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#120)' in ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) potentially used before declaration: retval == IERC1363Receiver.onTransferReceived.selector (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#121)
Variable 'ERC1363._checkOnTransferReceived(address,address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#122)' in ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) potentially used before declaration: reason.length == 0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#123)
Variable 'ERC1363._checkOnTransferReceived(address,address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#122)' in ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) potentially used before declaration: revert(uint256,uint256)(32 + reason,mload(uint256)(reason)) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#128)
Variable 'ERC1363._checkOnApprovalReceived(address,uint256,bytes).retval (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#151)' in ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) potentially used before declaration: retval == IERC1363Spender.onApprovalReceived.selector (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#152)
Variable 'ERC1363._checkOnApprovalReceived(address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#153)' in ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) potentially used before declaration: reason.length == 0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#154)
Variable 'ERC1363._checkOnApprovalReceived(address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#153)' in ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) potentially used before declaration: revert(uint256,uint256)(32 + reason,mload(uint256)(reason)) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#159)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#pre-declaration-usage-of-local-variables

Reentrancy in EScrow.withdraw(uint256) (src/4_EScrow.sol#48-64):
        External calls:
        - transaction.token.transfer(transaction.seller,transaction.amount) (src/4_EScrow.sol#59)
        Event emitted after the call(s):
        - Withdrawed(msg.sender,_tx_id,transaction.amount) (src/4_EScrow.sol#61)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-3

EScrow.withdraw(uint256) (src/4_EScrow.sol#48-64) uses timestamp for comparisons
        Dangerous comparisons:
        - require(bool,string)(transaction.lockedUntil > 0 && transaction.lockedUntil < block.timestamp,This escrow still locked) (src/4_EScrow.sol#52)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#block-timestamp

ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) uses assembly
        - INLINE ASM (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#127-129)
ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) uses assembly
        - INLINE ASM (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#158-160)
Address._revert(bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#231-243) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Address.sol#236-239)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage

EScrow.withdraw(uint256) (src/4_EScrow.sol#48-64) compares to a boolean constant:
        -require(bool,string)(transaction.withdrawExecuted == false,Withdrawn is already executed) (src/4_EScrow.sol#53)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#boolean-equality

Different versions of Solidity are used:
        - Version used: ['0.8.21', '^0.8.0', '^0.8.1']
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#3)
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363.sol#3)
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol#3)
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Spender.sol#3)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4)
        - ^0.8.1 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
        - 0.8.21 (src/4_EScrow.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used

Address.functionCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#89-91) is never used and should be removed
Address.functionCallWithValue(address,bytes,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#118-120) is never used and should be removed
Address.functionDelegateCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#170-172) is never used and should be removed
Address.functionDelegateCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#180-187) is never used and should be removed
Address.functionStaticCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#145-147) is never used and should be removed
Address.functionStaticCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#155-162) is never used and should be removed
Address.sendValue(address,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#64-69) is never used and should be removed
Address.verifyCallResult(bool,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#219-229) is never used and should be removed
Context._msgData() (lib/openzeppelin-contracts/contracts/utils/Context.sol#21-23) is never used and should be removed
ERC20._burn(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#277-293) is never used and should be removed
ERC20._mint(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#251-264) is never used and should be removed
ReentrancyGuard._reentrancyGuardEntered() (lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol#74-76) is never used and should be removed
SafeERC20._callOptionalReturnBool(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#134-142) is never used and should be removed
SafeERC20.forceApprove(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#82-89) is never used and should be removed
SafeERC20.safeApprove(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#45-54) is never used and should be removed
SafeERC20.safeDecreaseAllowance(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#69-75) is never used and should be removed
SafeERC20.safeIncreaseAllowance(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#60-63) is never used and should be removed
SafeERC20.safePermit(IERC20Permit,address,address,uint256,uint256,uint8,bytes32,bytes32) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#95-109) is never used and should be removed
SafeERC20.safeTransferFrom(IERC20,address,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#34-36) is never used and should be removed
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dead-code

Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#3) allows old versions
Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363.sol#3) allows old versions
Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol#3) allows old versions
Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Spender.sol#3) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4) allows old versions
Pragma version^0.8.1 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4) allows old versions
Pragma version0.8.21 (src/4_EScrow.sol#2) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.7
solc-0.8.21 is not recommended for deployment
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity

Low level call in SafeERC20._callOptionalReturnBool(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#134-142):
        - (success,returndata) = address(token).call(data) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#139)
Low level call in Address.sendValue(address,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#64-69):
        - (success) = recipient.call{value: amount}() (lib/openzeppelin-contracts/contracts/utils/Address.sol#67)
Low level call in Address.functionCallWithValue(address,bytes,uint256,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#128-137):
        - (success,returndata) = target.call{value: value}(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#135)
Low level call in Address.functionStaticCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#155-162):
        - (success,returndata) = target.staticcall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#160)
Low level call in Address.functionDelegateCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#180-187):
        - (success,returndata) = target.delegatecall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#185)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls

Function IERC20Permit.DOMAIN_SEPARATOR() (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#59) is not in mixedCase
Parameter EScrow.withdraw(uint256)._tx_id (src/4_EScrow.sol#48) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions

transferAndCall(address,uint256) should be declared external:
        - ERC1363.transferAndCall(address,uint256) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#31-33)
transferFromAndCall(address,address,uint256) should be declared external:
        - ERC1363.transferFromAndCall(address,address,uint256) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#55-57)
approveAndCall(address,uint256) should be declared external:
        - ERC1363.approveAndCall(address,uint256) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#84-86)
renounceOwnership() should be declared external:
        - Ownable.renounceOwnership() (lib/openzeppelin-contracts/contracts/access/Ownable.sol#61-63)
transferOwnership(address) should be declared external:
        - Ownable.transferOwnership(address) (lib/openzeppelin-contracts/contracts/access/Ownable.sol#69-72)
        - Ownable2Step.transferOwnership(address) (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#35-38)
acceptOwnership() should be declared external:
        - Ownable2Step.acceptOwnership() (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#52-56)
name() should be declared external:
        - ERC20.name() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#62-64)
symbol() should be declared external:
        - ERC20.symbol() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#70-72)
decimals() should be declared external:
        - ERC20.decimals() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#87-89)
totalSupply() should be declared external:
        - ERC20.totalSupply() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#94-96)
balanceOf(address) should be declared external:
        - ERC20.balanceOf(address) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#101-103)
increaseAllowance(address,uint256) should be declared external:
        - ERC20.increaseAllowance(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#177-181)
decreaseAllowance(address,uint256) should be declared external:
        - ERC20.decreaseAllowance(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#197-206)
onTransferReceived(address,address,uint256,bytes) should be declared external:
        - EScrow.onTransferReceived(address,address,uint256,bytes) (src/4_EScrow.sol#71-97)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#public-function-that-could-be-declared-external
</span>

## LinearBondingCurve

<span style="color:red">
LinearBondingCurve.onTransferReceived(address,address,uint256,bytes) (src/3_LinearBondingCurve.sol#122-137) sends eth to arbitrary user
        Dangerous calls:
        - (success) = address(sender).call{value: revenue}() (src/3_LinearBondingCurve.sol#133)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#functions-that-send-ether-to-arbitrary-destinations
</span>

<span style="color:yellow">
LinearBondingCurve.calculatePurchaseCost(uint256) (src/3_LinearBondingCurve.sol#74-84) performs a multiplication on the result of a division:
        -numerator = (_tokenAmount * (priceBeforeBuy + priceAfterBuy) / 2) * 10_000 (src/3_LinearBondingCurve.sol#81)
LinearBondingCurve.calculateSaleReturn(uint256) (src/3_LinearBondingCurve.sol#90-100) performs a multiplication on the result of a division:
        -numerator = (_tokenAmount * (priceBeforeSell + priceAfterSell) / 2) * 10_000 (src/3_LinearBondingCurve.sol#97)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#divide-before-multiply

ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) ignores return value by IERC1363Receiver(recipient).onTransferReceived(_msgSender(),sender,amount,data) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#120-131)
ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) ignores return value by IERC1363Spender(spender).onApprovalReceived(_msgSender(),amount,data) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#151-162)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
</span>

<span style="color:green">
LinearBondingCurve.constructor(string,string,uint256).name (src/3_LinearBondingCurve.sol#28) shadows:
        - ERC20.name() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#62-64) (function)
        - IERC20Metadata.name() (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#17) (function)
LinearBondingCurve.constructor(string,string,uint256).symbol (src/3_LinearBondingCurve.sol#28) shadows:
        - ERC20.symbol() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#70-72) (function)
        - IERC20Metadata.symbol() (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#22) (function)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#local-variable-shadowing

Ownable2Step.transferOwnership(address).newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#35) lacks a zero-check on :
                - _pendingOwner = newOwner (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#36)
LinearBondingCurve.onTransferReceived(address,address,uint256,bytes).sender (src/3_LinearBondingCurve.sol#122) lacks a zero-check on :
                - (success) = address(sender).call{value: revenue}() (src/3_LinearBondingCurve.sol#133)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation

Variable 'ERC1363._checkOnTransferReceived(address,address,uint256,bytes).retval (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#120)' in ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) potentially used before declaration: retval == IERC1363Receiver.onTransferReceived.selector (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#121)
Variable 'ERC1363._checkOnTransferReceived(address,address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#122)' in ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) potentially used before declaration: reason.length == 0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#123)
Variable 'ERC1363._checkOnTransferReceived(address,address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#122)' in ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) potentially used before declaration: revert(uint256,uint256)(32 + reason,mload(uint256)(reason)) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#128)
Variable 'ERC1363._checkOnApprovalReceived(address,uint256,bytes).retval (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#151)' in ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) potentially used before declaration: retval == IERC1363Spender.onApprovalReceived.selector (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#152)
Variable 'ERC1363._checkOnApprovalReceived(address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#153)' in ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) potentially used before declaration: reason.length == 0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#154)
Variable 'ERC1363._checkOnApprovalReceived(address,uint256,bytes).reason (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#153)' in ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) potentially used before declaration: revert(uint256,uint256)(32 + reason,mload(uint256)(reason)) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#159)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#pre-declaration-usage-of-local-variables

ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) uses assembly
        - INLINE ASM (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#127-129)
ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) uses assembly
        - INLINE ASM (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#158-160)
Address._revert(bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#231-243) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Address.sol#236-239)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage

Different versions of Solidity are used:
        - Version used: ['0.8.21', '^0.8.0', '^0.8.1']
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#3)
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363.sol#3)
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol#3)
        - ^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Spender.sol#3)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4)
        - ^0.8.1 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
        - 0.8.21 (src/3_LinearBondingCurve.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used

Address._revert(bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#231-243) is never used and should be removed
Address.functionCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#89-91) is never used and should be removed
Address.functionCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#99-105) is never used and should be removed
Address.functionCallWithValue(address,bytes,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#118-120) is never used and should be removed
Address.functionCallWithValue(address,bytes,uint256,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#128-137) is never used and should be removed
Address.functionDelegateCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#170-172) is never used and should be removed
Address.functionDelegateCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#180-187) is never used and should be removed
Address.functionStaticCall(address,bytes) (lib/openzeppelin-contracts/contracts/utils/Address.sol#145-147) is never used and should be removed
Address.functionStaticCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#155-162) is never used and should be removed
Address.isContract(address) (lib/openzeppelin-contracts/contracts/utils/Address.sol#40-46) is never used and should be removed
Address.sendValue(address,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#64-69) is never used and should be removed
Address.verifyCallResult(bool,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#219-229) is never used and should be removed
Address.verifyCallResultFromTarget(address,bool,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#195-211) is never used and should be removed
Context._msgData() (lib/openzeppelin-contracts/contracts/utils/Context.sol#21-23) is never used and should be removed
ReentrancyGuard._reentrancyGuardEntered() (lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol#74-76) is never used and should be removed
SafeERC20._callOptionalReturn(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#117-124) is never used and should be removed
SafeERC20._callOptionalReturnBool(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#134-142) is never used and should be removed
SafeERC20.forceApprove(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#82-89) is never used and should be removed
SafeERC20.safeApprove(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#45-54) is never used and should be removed
SafeERC20.safeDecreaseAllowance(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#69-75) is never used and should be removed
SafeERC20.safeIncreaseAllowance(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#60-63) is never used and should be removed
SafeERC20.safePermit(IERC20Permit,address,address,uint256,uint256,uint8,bytes32,bytes32) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#95-109) is never used and should be removed
SafeERC20.safeTransfer(IERC20,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#26-28) is never used and should be removed
SafeERC20.safeTransferFrom(IERC20,address,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#34-36) is never used and should be removed
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dead-code

Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#3) allows old versions
Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363.sol#3) allows old versions
Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol#3) allows old versions
Pragma version^0.8.0 (lib/erc1363-payable-token/contracts/token/ERC1363/IERC1363Spender.sol#3) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4) allows old versions
Pragma version^0.8.1 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4) allows old versions
Pragma version0.8.21 (src/3_LinearBondingCurve.sol#2) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.7
solc-0.8.21 is not recommended for deployment
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity

Low level call in SafeERC20._callOptionalReturnBool(IERC20,bytes) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#134-142):
        - (success,returndata) = address(token).call(data) (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#139)
Low level call in Address.sendValue(address,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#64-69):
        - (success) = recipient.call{value: amount}() (lib/openzeppelin-contracts/contracts/utils/Address.sol#67)
Low level call in Address.functionCallWithValue(address,bytes,uint256,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#128-137):
        - (success,returndata) = target.call{value: value}(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#135)
Low level call in Address.functionStaticCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#155-162):
        - (success,returndata) = target.staticcall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#160)
Low level call in Address.functionDelegateCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#180-187):
        - (success,returndata) = target.delegatecall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#185)
Low level call in LinearBondingCurve.sell(uint256) (src/3_LinearBondingCurve.sol#56-68):
        - (success,None) = address(_msgSender()).call{value: revenue}() (src/3_LinearBondingCurve.sol#66)
Low level call in LinearBondingCurve.onTransferReceived(address,address,uint256,bytes) (src/3_LinearBondingCurve.sol#122-137):
        - (success) = address(sender).call{value: revenue}() (src/3_LinearBondingCurve.sol#133)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls

Function IERC20Permit.DOMAIN_SEPARATOR() (lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#59) is not in mixedCase
Parameter LinearBondingCurve.buy(uint256)._tokenAmount (src/3_LinearBondingCurve.sol#40) is not in mixedCase
Parameter LinearBondingCurve.sell(uint256)._tokenAmount (src/3_LinearBondingCurve.sol#56) is not in mixedCase
Parameter LinearBondingCurve.calculatePurchaseCost(uint256)._tokenAmount (src/3_LinearBondingCurve.sol#74) is not in mixedCase
Parameter LinearBondingCurve.calculateSaleReturn(uint256)._tokenAmount (src/3_LinearBondingCurve.sol#90) is not in mixedCase
Parameter LinearBondingCurve.getPriceForSupply(uint256)._supply (src/3_LinearBondingCurve.sol#114) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions

transferAndCall(address,uint256) should be declared external:
        - ERC1363.transferAndCall(address,uint256) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#31-33)
transferFromAndCall(address,address,uint256) should be declared external:
        - ERC1363.transferFromAndCall(address,address,uint256) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#55-57)
approveAndCall(address,uint256) should be declared external:
        - ERC1363.approveAndCall(address,uint256) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#84-86)
renounceOwnership() should be declared external:
        - Ownable.renounceOwnership() (lib/openzeppelin-contracts/contracts/access/Ownable.sol#61-63)
transferOwnership(address) should be declared external:
        - Ownable.transferOwnership(address) (lib/openzeppelin-contracts/contracts/access/Ownable.sol#69-72)
        - Ownable2Step.transferOwnership(address) (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#35-38)
acceptOwnership() should be declared external:
        - Ownable2Step.acceptOwnership() (lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol#52-56)
name() should be declared external:
        - ERC20.name() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#62-64)
symbol() should be declared external:
        - ERC20.symbol() (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#70-72)
increaseAllowance(address,uint256) should be declared external:
        - ERC20.increaseAllowance(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#177-181)
decreaseAllowance(address,uint256) should be declared external:
        - ERC20.decreaseAllowance(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#197-206)
getCurrentPrice() should be declared external:
        - LinearBondingCurve.getCurrentPrice() (src/3_LinearBondingCurve.sol#105-107)
onTransferReceived(address,address,uint256,bytes) should be declared external:
        - LinearBondingCurve.onTransferReceived(address,address,uint256,bytes) (src/3_LinearBondingCurve.sol#122-137)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#public-function-that-could-be-declared-external
</span>
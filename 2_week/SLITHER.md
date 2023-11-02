# Slither

Run command: 
```
docker run --platform=linux/amd64 --rm -it -v ./:/share trailofbits/eth-security-toolbox  -c 'solc-select install 0.8.21 && solc-select use  0.8.21 && cd /share && slither --solc-remaps "@openzeppelin/=lib/openzeppelin-contracts/contracts @payabletoken/=lib/erc1363-payable-token/"  ./src'
```


## Result
<span style="color:yellow">
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        -denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#101)
        -inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#123)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        -denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#101)
        -inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#124)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        -denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#101)
        -inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#125)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) performs a multiplication on the result of a division:
        -prod0 = prod0 / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#104)
        -result = prod0 * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#131)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#divide-before-multiply

</br>
ERC721._checkOnERC721Received(address,address,uint256,bytes) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#399-421) ignores return value by IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#406-417)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
</br>
ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) ignores return value by IERC1363Receiver(recipient).onTransferReceived(_msgSender(),sender,amount,data) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#120-131)
ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) ignores return value by IERC1363Spender(spender).onApprovalReceived(_msgSender(),amount,data) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#151-162)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return

</br>
StakeAndGetReward.unstake(uint256) (src/2_StakeAndGetReward.sol#69-82) uses a dangerous strict equality:
        - require(bool,string)(nftDeposit.owner == _msgSender(),Only address who initaly staked NFT can un stake it.) (src/2_StakeAndGetReward.sol#71)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dangerous-strict-equalities

</br>
ERC1363._checkOnTransferReceived(address,address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#110-132) ignores return value by IERC1363Receiver(recipient).onTransferReceived(_msgSender(),sender,amount,data) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#120-131)
ERC1363._checkOnApprovalReceived(address,uint256,bytes) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#142-163) ignores return value by IERC1363Spender(spender).onApprovalReceived(_msgSender(),amount,data) (lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol#151-162)
StakeAndGetReward.unstake(uint256) (src/2_StakeAndGetReward.sol#69-82) ignores return value by rewardTokenContract.mint(_msgSender(),rewardAmount) (src/2_StakeAndGetReward.sol#76)
StakeAndGetReward.collectReward(uint256) (src/2_StakeAndGetReward.sol#88-100) ignores return value by rewardTokenContract.mint(_msgSender(),rewardAmount) (src/2_StakeAndGetReward.sol#95)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
</span>

</br>
<span style="color:green">
        - PresaleMinted(_msgSender(),tokenId) (src/1_NftWithMerkleAndRoyalties.sol#79)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-3

ERC721._checkOnERC721Received(address,address,uint256,bytes) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#399-421) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#413-415)
Address._revert(bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#231-243) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Address.sol#236-239)
Strings.toString(uint256) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#19-39) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#25-27)
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#31-33)
MerkleProof._efficientHash(bytes32,bytes32) (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#219-226) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#221-225)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#62-66)
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#85-92)
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#99-108)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage

NftWithMerkleAndRoyalties.preSaleMint(uint256,bytes32[]) (src/1_NftWithMerkleAndRoyalties.sol#55-82) compares to a boolean constant:
        -require(bool,string)(BitMaps.get(mintedTokens,_mintPass) == false,Discount Mint pass already used.) (src/1_NftWithMerkleAndRoyalties.sol#68)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#boolean-equality

Different versions of Solidity are used:
        - Version used: ['0.8.21', '^0.8.0', '^0.8.1']
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/interfaces/IERC2981.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol#4)
        - ^0.8.1 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/Strings.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#4)
        - ^0.8.0 (lib/openzeppelin-contracts/contracts/utils/structs/BitMaps.sol#3)
        - 0.8.21 (src/1_NftWithMerkleAndRoyalties.sol#2)
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
Address.sendValue(address,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#64-69) is never used and should be removed
Address.verifyCallResult(bool,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#219-229) is never used and should be removed
Address.verifyCallResultFromTarget(address,bool,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#195-211) is never used and should be removed
Context._msgData() (lib/openzeppelin-contracts/contracts/utils/Context.sol#21-23) is never used and should be removed
ERC2981._deleteDefaultRoyalty() (lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol#82-84) is never used and should be removed
ERC2981._resetTokenRoyalty(uint256) (lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol#104-106) is never used and should be removed
ERC2981._setTokenRoyalty(uint256,address,uint96) (lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol#94-99) is never used and should be removed
</br>
ERC721.__unsafe_increaseBalance(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#463-465) is never used and should be removed
ERC721._burn(uint256) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#299-320) is never used and should be removed
Math.average(uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#34-37) is never used and should be removed
Math.ceilDiv(uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#45-48) is never used and should be removed
Math.log10(uint256,Math.Rounding) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#290-295) is never used and should be removed
Math.log2(uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#199-235) is never used and should be removed
Math.log2(uint256,Math.Rounding) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#241-246) is never used and should be removed
Math.log256(uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#303-327) is never used and should be removed
Math.log256(uint256,Math.Rounding) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#333-338) is never used and should be removed
Math.max(uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#19-21) is never used and should be removed
Math.min(uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#26-28) is never used and should be removed
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#55-134) is never used and should be removed
Math.mulDiv(uint256,uint256,uint256,Math.Rounding) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#139-145) is never used and should be removed
Math.sqrt(uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#152-183) is never used and should be removed
Math.sqrt(uint256,Math.Rounding) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#188-193) is never used and should be removed
MerkleProof.multiProofVerify(bytes32[],bool[],bytes32,bytes32[]) (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#77-84) is never used and should be removed

</br>
MerkleProof.multiProofVerifyCalldata(bytes32[],bool[],bytes32,bytes32[]) (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#93-100) is never used and should be removed
MerkleProof.processMultiProof(bytes32[],bool[],bytes32[]) (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#114-159) is never used and should be removed
MerkleProof.processMultiProofCalldata(bytes32[],bool[],bytes32[]) (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#168-213) is never used and should be removed
MerkleProof.processProofCalldata(bytes32[],bytes32) (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#61-67) is never used and should be removed
MerkleProof.verifyCalldata(bytes32[],bytes32,bytes32) (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#36-38) is never used and should be removed
SignedMath.abs(int256) (lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#37-42) is never used and should be removed
SignedMath.average(int256,int256) (lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#28-32) is never used and should be removed
SignedMath.max(int256,int256) (lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#13-15) is never used and should be removed
SignedMath.min(int256,int256) (lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#20-22) is never used and should be removed
Strings.equal(string,string) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#82-84) is never used and should be removed
Strings.toHexString(address) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#75-77) is never used and should be removed
Strings.toHexString(uint256) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#51-55) is never used and should be removed
Strings.toHexString(uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#60-70) is never used and should be removed
Strings.toString(int256) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#44-46) is never used and should be removed
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dead-code

Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/interfaces/IERC2981.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol#4) allows old versions
Pragma version^0.8.1 (lib/openzeppelin-contracts/contracts/utils/Address.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/Strings.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#4) allows old versions
Pragma version^0.8.0 (lib/openzeppelin-contracts/contracts/utils/structs/BitMaps.sol#3) allows old versions
Pragma version0.8.21 (src/1_NftWithMerkleAndRoyalties.sol#2) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.7
solc-0.8.21 is not recommended for deployment
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity

Low level call in Address.sendValue(address,uint256) (lib/openzeppelin-contracts/contracts/utils/Address.sol#64-69):
        - (success) = recipient.call{value: amount}() (lib/openzeppelin-contracts/contracts/utils/Address.sol#67)
Low level call in Address.functionCallWithValue(address,bytes,uint256,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#128-137):
        - (success,returndata) = target.call{value: value}(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#135)
Low level call in Address.functionStaticCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#155-162):
        - (success,returndata) = target.staticcall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#160)
Low level call in Address.functionDelegateCall(address,bytes,string) (lib/openzeppelin-contracts/contracts/utils/Address.sol#180-187):
        - (success,returndata) = target.delegatecall(data) (lib/openzeppelin-contracts/contracts/utils/Address.sol#185)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls

Function ERC721.__unsafe_increaseBalance(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#463-465) is not in mixedCase
Parameter NftWithMerkleAndRoyalties.preSaleMint(uint256,bytes32[])._mintPass (src/1_NftWithMerkleAndRoyalties.sol#55) is not in mixedCase
Parameter NftWithMerkleAndRoyalties.preSaleMint(uint256,bytes32[])._merkleProof (src/1_NftWithMerkleAndRoyalties.sol#55) is not in mixedCase
Constant NftWithMerkleAndRoyalties.defaultFeeNumerator (src/1_NftWithMerkleAndRoyalties.sol#23) is not in UPPER_CASE_WITH_UNDERSCORES
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions

NftWithMerkleAndRoyalties.discountedMintPriceInWei (src/1_NftWithMerkleAndRoyalties.sol#26) should be constant
NftWithMerkleAndRoyalties.mintPriceInWei (src/1_NftWithMerkleAndRoyalties.sol#25) should be constant
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#state-variables-that-could-be-declared-constant

balanceOf(address) should be declared external:
        - ERC721.balanceOf(address) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#62-65)
name() should be declared external:
        - ERC721.name() (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#79-81)
symbol() should be declared external:
        - ERC721.symbol() (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#86-88)
tokenURI(uint256) should be declared external:
        - ERC721.tokenURI(uint256) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#93-98)
approve(address,uint256) should be declared external:
        - ERC721.approve(address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#112-122)
setApprovalForAll(address,bool) should be declared external:
        - ERC721.setApprovalForAll(address,bool) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#136-138)
transferFrom(address,address,uint256) should be declared external:
        - ERC721.transferFrom(address,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#150-155)
safeTransferFrom(address,address,uint256) should be declared external:
        - ERC721.safeTransferFrom(address,address,uint256) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#160-162)
royaltyInfo(uint256,uint256) should be declared external:
        - ERC2981.royaltyInfo(uint256,uint256) (lib/openzeppelin-contracts/contracts/token/common/ERC2981.sol#43-53)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#public-function-that-could-be-declared-external
</span>


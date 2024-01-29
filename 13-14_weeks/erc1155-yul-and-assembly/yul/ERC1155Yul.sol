/**
 * @title ERC1155 in Yul. EIP => https://eips.ethereum.org/EIPS/eip-1155
 */

object "ERC1155Yul" {   
    /**
     * @dev return runtime code
     */
    code {
        // return contract runtimecode
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime" {
    /**
     * @dev runtime code
     */
        code {
            setCurrentFreeMemorySlot(0x80)
            /* ----------------- FUNCTION SELECTORS ------------------ */

            switch getFunctionSelector()

            // --------- mint(address,uint256,uint256,bytes) ---------- //
            case 0x731133e9 {
                let to := decodeAsAddress(0)
                assertNonZeroAddress(to)

                let tokenId := decodeAsAddress(1)            
                let amount := decodeAsUint(2)    

                mint(to, tokenId, amount)
                
                // operator == caller() when minting, from == zero addr, rest is given as input
                emitTransferSingle(caller(), 0, to, tokenId, amount)
            }

            // ----- batchMint(address,uint256[],uint256[],bytes) ----- //
            case 0xb48ab8b6 {
                let to := decodeAsAddress(0)
                let tokenIdsCalldataOffset := decodeAsUint(1)
                let amountsCalldataOffset := decodeAsUint(2)

                let tokenIdsLength := calldataloadSkipFnSelector(tokenIdsCalldataOffset) 
                let amountsLength := calldataloadSkipFnSelector(amountsCalldataOffset)

                assertNonZeroAddress(to)
                assertArraysLengthsAreSame(tokenIdsLength, amountsLength)
                
                for { let i := 0 } lt(i, tokenIdsLength) { i := add(i, 1) } {
                    // load values by 32 bytes
                    let tokenId := calldataloadSkipFnSelector(add(tokenIdsCalldataOffset, mul(add(i, 1), 0x20)))
                    let amount := calldataloadSkipFnSelector(add(amountsCalldataOffset, mul(add(i, 1), 0x20)))
                    mint(to, tokenId, amount)
                }
                // pass in: operator, from, to, tokenIds, amounts. last two will be handled inside emit function
                emitTransferBatch(caller(), 0, to, tokenIdsCalldataOffset, amountsCalldataOffset)
            }

            // ------------- balanceOf(address,uint256) --------------- //
            case 0x00fdd58e {
                returnUint(balanceOfAddress(decodeAsAddress(0), decodeAsUint(1)))                      
            }

            // -- balanceOfBatch(address[], uint256[]) -- //
            case 0x4e1273f4 {
                // get pointers where length of arrays are stored
                let ownersCalldataOffset := decodeAsUint(0)
                let tokenIdsCalldataOffset := decodeAsUint(1)
                let ownersLength := calldataloadSkipFnSelector(ownersCalldataOffset) 
                let tokenIdsLength := calldataloadSkipFnSelector(tokenIdsCalldataOffset)
                
                assertArraysLengthsAreSame(ownersLength, tokenIdsLength)

                // in order to return array we need following
                // 0x00 - 0x20 => offset
                // 0x20 - 0x40 => array length
                // 0x40 - .... => array values
                // all combined togeter is final memory size for returning
                /// 0x20 + 0x20 + 0x20 * length = 0x40 + 0x20 * length
                let finalMemorySize := add(0x40, mul(tokenIdsLength, 0x20))

                // store array offset
                let initialFreeMemorySlot := currentFreeMemorySlot()
                mstore(currentFreeMemorySlot(), 0x20)
                incrementCurrentFreeMemorySlot()

                // store length of array
                mstore(currentFreeMemorySlot(), tokenIdsLength)
                incrementCurrentFreeMemorySlot()
                
                // loop trough addresses and tokenIds and return balance for provided pair at same index
                for { let i := 0 } lt(i, tokenIdsLength) { i := add(i, 1) } {
                    let owner := calldataloadSkipFnSelector(add(ownersCalldataOffset, mul(add(i, 1), 0x20)))
                    let tokenId := calldataloadSkipFnSelector(add(tokenIdsCalldataOffset, mul(add(i, 1), 0x20)))
                    let amount := balanceOfAddress(owner, tokenId)

                    mstore(currentFreeMemorySlot(), amount)
                    incrementCurrentFreeMemorySlot()
                }
                return(initialFreeMemorySlot, finalMemorySize)
            }

            // ------------ setApprovalForAll(address,bool) ----------- //
            case 0xa22cb465 {
                let operator := decodeAsAddress(0)
                let isApproved := decodeAsUint(1)
                let slot := nestedStorageSlot(isApprovedForAllBaseSlot(), caller(), operator)
                sstore(slot, isApproved)
                emitApprovalForAll(caller(), operator, isApproved)
                return(0, 0)
            }

            // ---------- isApprovedForAll(address,address) ----------- //
            case 0xe985e9c5 {
                let isApproved := isApprovedForAll(decodeAsAddress(0), decodeAsAddress(1))
                mstore(0x00, isApproved)
                return(0, 0x20)
            }
            
            // safeTransferFrom(address,address,uint256,uint256,bytes)  //
            case 0xf242432a  {
                let from := decodeAsAddress(0)
                let to := decodeAsAddress(1)
                let tokenId := decodeAsUint(2)
                let amount := decodeAsUint(3)


                let fromSlot := nestedStorageSlot(balanceOfBaseSlot(), from, tokenId)
                let fromBalance := sload(fromSlot)

                // validate balance, check if to address is zero and valdiate is there correct approval for this action
                assertValidBalance(fromBalance, amount)
                assertIfSenderHasApproval(from)
                assertNonZeroAddress(to)

                sstore(fromSlot, sub(fromBalance, amount))

                let toSlot := nestedStorageSlot(balanceOfBaseSlot(), to, tokenId)
                
                sstore(toSlot, safeAdd(sload(toSlot), amount))
                emitTransferSingle(caller(), from, to, tokenId, amount)
            }                

            // safeBatchTransferFrom(address,address,uint256[],uint256[],bytes) //
            case 0x2eb2c2d6  {
                let from := decodeAsAddress(0)
                let to := decodeAsAddress(1)

                // get pointers where length of arrays are stored
                let tokenIdsCalldataOffset := decodeAsUint(2)
                let amountsCalldataOffset := decodeAsUint(3)
                let tokenIdsLength := calldataloadSkipFnSelector(tokenIdsCalldataOffset) 
                let amountsLength := calldataloadSkipFnSelector(amountsCalldataOffset)

                // check for same length arrays, correct receiver & approval / ownership 
                assertIfSenderHasApproval(from)
                assertArraysLengthsAreSame(tokenIdsLength, amountsLength)
                assertNonZeroAddress(to)
                
                // loop and get the balances from the given slots & ids and store them
                for { let i := 0 } lt(i, tokenIdsLength) { i := add(i, 1) } {
                    
                    // tokenId and amount from calldata
                    let tokenId := calldataloadSkipFnSelector(add(tokenIdsCalldataOffset, mul(add(i, 1), 0x20)))
                    let amount := calldataloadSkipFnSelector(add(amountsCalldataOffset, mul(add(i, 1), 0x20)))
                    // storage slots to store balances
                    let fromSlot := nestedStorageSlot(balanceOfBaseSlot(), from, tokenId)
                    let toSlot := nestedStorageSlot(balanceOfBaseSlot(), to, tokenId)
                    let fromBalance := balanceOfAddress(from, tokenId)

                    assertValidBalance(fromBalance, amount)

                    // update from and to balances
                    sstore(fromSlot, sub(sload(fromSlot), amount))
                    sstore(toSlot, safeAdd(sload(toSlot), amount))
                }

                emitTransferBatch(caller(), from, to, tokenIdsCalldataOffset, amountsCalldataOffset)
            }
            
            // ------------------------- uri(uint256) ------------------------- //
            case 0x0e89341C {
                let stringLength := sload(uriSlot())
                let startOfMemory := currentFreeMemorySlot()

                mstore(startOfMemory, 0x20)  // store pointer to where the string will start
                mstore(add(startOfMemory, 0x20), stringLength) // store string length

                setCurrentFreeMemorySlot(add(startOfMemory, 0x40)) // advance memory pointer to prepare for loop
                mstore(0, uriSlot())  // store storage slot of uri in memory to get hash
                let startingSlot := keccak256(0, 0x20) // get hash of storage slot

                let numberOfSLots := div(stringLength, 0x20) // number of storage slots the uri takes to be stored
                // when stringLength % 0x20 is not 0 then add one more slot
                if mod(stringLength, 0x20) {
                    numberOfSLots := add(numberOfSLots, 1)
                }

                // loop over slots amount and store all parts of the string in memory
                for { let i := 0 } lt(i, numberOfSLots) { i := add(i, 1) } {
                    let partialString := sload(safeAdd(startingSlot,i))
                    mstore(currentFreeMemorySlot(), partialString)
                    incrementCurrentFreeMemorySlot()
                }

                return(startOfMemory, currentFreeMemorySlot())
            }
            
            // ---------------------------------------------------------------- //
            // ------------------------ setURI(string) ------------------------ //
            // same uri for all events. uri url should be parametirzed so clients can change id param in url to get uri for token id.
            // https://docs.openzeppelin.com/contracts/4.x/api/token/erc1155#ERC1155-_setURI-string-
            // https://docs.openzeppelin.com/contracts/4.x/api/token/erc1155#ERC1155-uri-uint256-
            // https://docs.openzeppelin.com/contracts/4.x/api/token/erc1155#IERC1155-URI-string-uint256-
            // https://eips.ethereum.org/EIPS/eip-1155#metadata
            // ---------------------------------------------------------------- //
            case 0x02fe5305 {
                // get pointer & length of string
                let stringCalldataOffset := decodeAsUint(0)
                let stringLength := calldataloadSkipFnSelector(stringCalldataOffset)

                mstore(0, uriSlot())                        
                let stringStorageSlot := keccak256(0, 0x20) // hash of uri storage slot
                sstore(uriSlot(), stringLength)             // store uri length in uriSlot

                let numberOfSlots := div(stringLength, 0x20) // number of storage slots the uri takes to be stored
                // when stringLength % 0x20 is not 0 then add one more slot
                if mod(stringLength, 0x20) {
                    numberOfSlots := add(numberOfSlots, 1)
                }

                // loop over slots amount and store all parts of the string in memory
                for { let i := 0 } lt(i, numberOfSlots) { i := add(i, 1) } {
                    
                    // extract part of string based on length and offset
                    let partialString := calldataloadSkipFnSelector(add(mul(0x20, add(i, 1)), stringCalldataOffset))
                    
                    // store part of uri on calculated storageSlot increased by i
                    sstore(add(stringStorageSlot, i), partialString)
                }

                // https://eips.ethereum.org/EIPS/eip-1155#metadata
                // The URI value allows for ID substitution by clients. If the string {id} exists in any URI, clients MUST replace this with the actual token ID in hexadecimal form. 
                // This allows for a large number of tokens to use the same on-chain string by defining a URI once, for that large number of tokens.
                // as event needs to contain id, we just put 0 here, it will be same any url set, as it is not stored on chain by id
                emitURI(0)
            }

            // if invalid selector is provided then revert
            default {
                revert(0, 0)
            }

            /* ---------------- FUNCTIONS -------------------------------- */

            /* ---------------- HELPER FUNCTIONS ------------------------- */
            function mint(to, tokenId, amount) {
                let slot := nestedStorageSlot(balanceOfBaseSlot(), to, tokenId)
                // add balance to same slot if already exist
                sstore(slot, safeAdd(sload(slot), amount))
            }

            function balanceOfAddress(account, tokenId) -> balanceOf {
                let slot := nestedStorageSlot(balanceOfBaseSlot(), account, tokenId)
                balanceOf := sload(slot)
            }
            
            function isApprovedForAll(account,operator) -> isApproved {
                let slot := nestedStorageSlot(isApprovedForAllBaseSlot(), account, operator)
                isApproved := sload(slot)
            }

            function assertArraysLengthsAreSame(length1, length2) {
                if iszero(eq(length1, length2)) {
                    // revert msg: 'LENGTH_MISMATCH' hex value left padded
                    mstore(0x00, 0x4c454e4754485f4d49534d415443480000000000000000000000000000000000)
                    revert(0x00, 0x20)
                }
            }

            function assertNonZeroAddress(to) {
                if iszero(to) {
                    // revert msg: 'ZERO_ADDRESS'
                    mstore(0x00, 0x5a45524f5f414444524553530000000000000000000000000000000000000000)
                    revert(0x00, 0x20)
                }
            }

            function assertIfSenderHasApproval(from) {
                // sender can be owner or it has approval for sending
                if iszero(or(eq(caller(), from), isApprovedForAll(from, caller()))) {
                    // revert msg: `MISSING_APPROVAL_FOR_ALL` hex value left padded
                    mstore(0x00, 0x4d495353494e475f415050524f56414c5f464f525f414c4c0000000000000000)
                    revert(0x00, 0x20)
                }
            }

            function assertValidBalance(fromBalance, amount) {
                if iszero(gte(fromBalance, amount)) {
                    // revert msg: INSUFFICIENT_BALANCE
                    mstore(0x00, 0x494e53554646494349454e545f42414c414e4345000000000000000000000000)
                    revert(0x00, 0x20)
                }
            }

            /* --------------------- STORAGE LAYOUT ---------------------- */
            function balanceOfBaseSlot() -> baseSlot { baseSlot := 0 } 
            function isApprovedForAllBaseSlot() -> baseSlot { baseSlot := 1 }
            function uriSlot() -> baseSlot { baseSlot := 2 }

            /* ---------------- STORAGE HELPER FUNCTIONS ---------------- */
            function nestedStorageSlot(baseSlot, param1, param2) -> slot {
                mstore(0x00, baseSlot)                       
                mstore(0x20, param1)                            
                mstore(0x40, param2)                            

                slot := keccak256(0x00, 0x60)
            }

            /* --------------------- MEMORY LAYOUT ---------------------- */
            // 0x00 - 0x20 => scratch space for hashing methods
            // 0x20 - 0x40 => scratch space for hashing methods
            // 0x20 - 0x60 => scratch space for hashing methods
            // 0x60 - 0x80 => free memory pointer
            // 0x80 - ...  => free memory
            function freeMemoryPointerPosition() -> position { position := 0x60 }
            /* ---------------- MEMORY HELPER FUNCTIONS ----------------- */
            

            function currentFreeMemorySlot() -> value {
                value := mload(freeMemoryPointerPosition())
            }

            function incrementCurrentFreeMemorySlot() {
                mstore(freeMemoryPointerPosition(), add(currentFreeMemorySlot(), 0x20))
            }

            function setCurrentFreeMemorySlot(newSlot) {
                mstore(freeMemoryPointerPosition(), newSlot)
            }

            /* -------------- EMIT EVENTS HELPER FUNCTIONS -------------- */
            function emitTransferSingle(operator, from, to, tokenId, amount) {
                // keccak256 of "TransferSingle(address,address,address,uint256,uint256)"
                let signatureHash := 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62
                
                // use scratch space to store non indexed values from 0x00 - 0x40
                mstore(0, tokenId)
                mstore(0x20, amount)
                log4(0, 0x40, signatureHash, operator, from, to)
            }

            function emitTransferBatch(operator, from, to, tokenIdsCalldataOffset, amountsCalldataOffset) {
                // keccak256 of "TransferBatch(address,address,address,uint256[],uint256[])"
                let signatureHash := 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb
                
                let tokenIdsLength := calldataloadSkipFnSelector(tokenIdsCalldataOffset) 
                let amountsLength := calldataloadSkipFnSelector(amountsCalldataOffset)

                // in order to store one array we need following
                // 0x00 - 0x20 => offset
                // 0x20 - 0x40 => array length
                // 0x40 - .... => array values
                // all combined togeter is final memory size for returning
                /// 0x20 + 0x20 + 0x20 * length = 0x40 + 0x20 * length
                // so for this usage we need two times this.
                let finalMemorySize := add(0x80, mul(mul(tokenIdsLength, 2), 0x20))

                // arrays offset. first starts on 0x40 and second is 0x20 * (array length + 1)
                let tokenIdsStart := 0x40
                let amountsStart := add(0x40, mul(add(1, amountsLength), 0x20))

                mstore(0x00, tokenIdsStart)           // store offest tokenIds
                mstore(0x20, amountsStart)            // store offset amounts

                copyArrayToMemory(tokenIdsStart, tokenIdsCalldataOffset)
                copyArrayToMemory(amountsStart, amountsCalldataOffset)

                log4(0x00, finalMemorySize, signatureHash, operator, from, to)
            }

            function emitApprovalForAll(owner, operator, isApproved) {
                // keccak256 of "ApprovalForAll(address,address,bool)"
                let signatureHash := 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31
                mstore(0, isApproved)
                log3(0, 0x20, signatureHash, owner, operator)
            }
    
            function emitURI(tokenId) {
                // keccak256 of "URI(string,uint256)"
                let signatureHash := 0x6bb7ff708619ba0610cba295a58592e0451dee2622938c8755667688daf3529b
                
                let stringLength := sload(uriSlot())
                let startOfMemory := currentFreeMemorySlot()

                mstore(startOfMemory, 0x20)  // store pointer to where the string will start
                mstore(add(startOfMemory, 0x20), stringLength) // store string length

                setCurrentFreeMemorySlot(add(startOfMemory, 0x40)) // advance memory pointer to prepare for loop
                mstore(0, uriSlot())  // store storage slot of uri in memory to get hash
                let startingSlot := keccak256(0, 0x20) // get hash of storage slot

                let numberOfSLots := div(stringLength, 0x20) // number of storage slots the uri takes to be stored
                // when stringLength % 0x20 is not 0 then add one more slot
                if mod(stringLength, 0x20) {
                    numberOfSLots := add(numberOfSLots, 1)
                }

                // loop over slots amount and store all parts of the string in memory
                for { let i := 0 } lt(i, numberOfSLots) { i := add(i, 1) } {
                    let partialString := sload(safeAdd(startingSlot,i))
                    mstore(currentFreeMemorySlot(), partialString)
                    incrementCurrentFreeMemorySlot()
                }

                log2(startOfMemory, currentFreeMemorySlot(), signatureHash, tokenId)
            }

            /* -------- HELPER FUNCTIONS FOR CALLDATA DECODING  --------- */
            
            /**
             * @dev extract the function selector from the calldata
             */
            function getFunctionSelector() -> selector {
                selector := shr(224, calldataload(0x00))
            }

            /**
             * @dev adds 4 bytes when calldataloading to skip the func selector
             */
            function calldataloadSkipFnSelector(slotWithoutFnSelectorOffset) -> value {
                value := calldataload(add(4, slotWithoutFnSelectorOffset))
            }

            /**
             * @dev check that only address 20 bytes are present
             */
            function decodeAsAddress(offset) -> value {
                value := decodeAsUint(offset)
                if iszero(iszero(and(value, not(0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff)))) {
                    revert(0, 0)
                }
            }

            /**
             * @dev skips fn selector and returns 32 bytes result based on offset
             */
            function decodeAsUint(offset) -> value {
                let pos := add(4, mul(offset, 0x20))
                if lt(calldatasize(), add(pos, 0x20)) {
                    revert(0, 0)
                }
                value := calldataload(pos)
            }

            /* ---------- HELPER FUNCTIONS FOR RETURN DATA ----------- */
            /**
             * @dev usess call data copy, to copy range of slots which is needed for array
             */
            function copyArrayToMemory(memoryPointer, arrOffset) {
                let arrLenOffset := add(arrOffset, 4)        // skip fn selector
                let arrLen := calldataload(arrLenOffset)     // load arr length
                let totalLen := add(0x20, mul(arrLen, 0x20)) // len+arrData
                calldatacopy(memoryPointer, arrLenOffset, totalLen) // copy len+data
            }

            /**
             * @dev stores the value in memory 0x00 and returns that part of memory
             */
            function returnUint(v) {
                mstore(0, v)
                return(0, 0x20)
            }

            /* -------------- MATH HELPER FUNCTIONS --------------- */
            function lte(a, b) -> r {
                r := iszero(gt(a, b))
            }

            function gte(a, b) -> r {
                r := iszero(lt(a, b))
            }

            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }

            // Overflow & Underflow Protection
            function safeAdd(a, b) -> r {
                r := add(a, b)
                if or(lt(r, a), lt(r, b)) { revert(0, 0) }
            }

            function safeSub(a, b) -> r {
                r := sub(a, b)
                if gt(r, a) { revert(0, 0) }
            }
        }
    }

}
/**
 * @title ERC1155 in Yul. EIP => https://eips.ethereum.org/EIPS/eip-1155
 */

object "ERC1155Yul" {   
    /**
     * @notice Constructor
     */
    code {
        // Basic constructor
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime" {
    /**
     * @notice Deployed contracts runtime code
     */
        code {
            setCurrentFreeMemorySlot(0x80)
            
            /* ------------------------------------------------------- */
            /* ----------------- FUNCTION SELECTORS ------------------ */
            /* ------------------------------------------------------- */

            switch getSelector()
            // -------------------------------------------------------- //
            // --------- mint(address,uint256,uint256,bytes) ---------- //
            // -------------------------------------------------------- //
            case 0x731133e9 {
                let to := decodeAsAddress(0)
                assertNonZeroAddress(to)

                let tokenId := decodeAsAddress(1)            
                let amount := decodeAsUint(2)    

                mint(to, tokenId, amount)
                // operator == caller() when minting, from == zero addr, rest is given as input
                emitTransferSingle(caller(), 0, to, tokenId, amount)
            }

            // -------------------------------------------------------- //
            // ----- batchMint(address,uint256[],uint256[],bytes) ----- //
            // -------------------------------------------------------- //
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

            // -------------------------------------------------------- //
            // ------------- balanceOf(address,uint256) --------------- //
            // -------------------------------------------------------- //
            case 0x00fdd58e {
                returnUint(balanceOfAddress(decodeAsAddress(0), decodeAsUint(1)))                      
            }

            // -------------------------------------------------------- //
            // -- balanceOfBatch(address[], uint256[]) -- //
            // -------------------------------------------------------- //
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
                
                // loop and get the balances from the given slots & ids and store them
                for { let i := 0 } lt(i, tokenIdsLength) { i := add(i, 1) } {
                    let owner := calldataloadSkipFnSelector(add(ownersCalldataOffset, mul(add(i, 1), 0x20)))
                    let tokenId := calldataloadSkipFnSelector(add(tokenIdsCalldataOffset, mul(add(i, 1), 0x20)))
                    let amount := balanceOfAddress(owner, tokenId)

                    mstore(currentFreeMemorySlot(), amount)
                    incrementCurrentFreeMemorySlot()
                }
                return(initialFreeMemorySlot, finalMemorySize)
            }

            // -------------------------------------------------------- //
            // ------------ setApprovalForAll(address,bool) ----------- //
            // -------------------------------------------------------- //
            case 0xa22cb465 {
                let operator := decodeAsAddress(0)
                let isApproved := decodeAsUint(1)
                let slot := nestedStorageSlot(isApprovedForAllBaseSlot(), caller(), operator)
                sstore(slot, isApproved)
                emitApprovalForAll(caller(), operator, isApproved)
                return(0, 0)
            }

            // -------------------------------------------------------- //
            // ---------- isApprovedForAll(address,address) ----------- //
            // -------------------------------------------------------- //
            case 0xe985e9c5 {
                let isApproved := isApprovedForAll(decodeAsAddress(0), decodeAsAddress(1))
                mstore(0x00, isApproved)
                return(0, 0x20)
            }
            
            // -------------------------------------------------------- //
            // safeTransferFrom(address,address,uint256,uint256,bytes)  //
            // -------------------------------------------------------- //
            case 0xf242432a  {
                let from := decodeAsAddress(0)
                let to := decodeAsAddress(1)
                let tokenId := decodeAsUint(2)
                let amount := decodeAsUint(3)


                let fromSlot := nestedStorageSlot(balanceOfBaseSlot(), from, tokenId)
                let fromBalance := sload(fromSlot)

                // check for sufficient balance, correct to address & approval / ownership 
                assertValidBalance(fromBalance, amount)
                assertIfSenderHasApproval(from)
                assertNonZeroAddress(to)

                // already checked for underflow => use sub instead of safeSub
                sstore(fromSlot, sub(fromBalance, amount))

                let toSlot := nestedStorageSlot(balanceOfBaseSlot(), to, tokenId)
                // sload the old balance and safeAdd "amount" then store the result as the new balance
                sstore(toSlot, safeAdd(sload(toSlot), amount))
                emitTransferSingle(caller(), from, to, tokenId, amount)
            }                

            // ---------------------------------------------------------------- //
            // safeBatchTransferFrom(address,address,uint256[],uint256[],bytes) //
            // ---------------------------------------------------------------- //
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
                    // get tokenId and amount from calldata
                    let tokenId := calldataloadSkipFnSelector(add(tokenIdsCalldataOffset, mul(add(i, 1), 0x20)))
                    let amount := calldataloadSkipFnSelector(add(amountsCalldataOffset, mul(add(i, 1), 0x20)))
                    // get mapping slots to store the new balances
                    let fromSlot := nestedStorageSlot(balanceOfBaseSlot(), from, tokenId)
                    let toSlot := nestedStorageSlot(balanceOfBaseSlot(), to, tokenId)
                    let fromBalance := balanceOfAddress(from, tokenId)

                    // revert with NOT_ENOUGH_BALANCE => infos for user + underflow protection
                    assertValidBalance(fromBalance, amount)

                    // get oldBalance from slot and safeAdd the amount + overflow protection
                    sstore(fromSlot, sub(sload(fromSlot), amount))
                    sstore(toSlot, safeAdd(sload(toSlot), amount))
                }
                // pass in: operator, from, to, tokenIds, amounts. last two will be handled inside emit function
                emitTransferBatch(caller(), from, to, tokenIdsCalldataOffset, amountsCalldataOffset)
            }
            
            // ---------------------------------------------------------------- //
            // ------------------------- uri(uint256) ------------------------- //
            // ---------------------------------------------------------------- //
            case 0x0e89341C {
                let stringLength := sload(uriLengthSlot())
                let startOfMemory := currentFreeMemorySlot()
                mstore(startOfMemory, 0x20)  // store pointer to where the string will start
                mstore(add(startOfMemory, 0x20), stringLength) // store string length
                setCurrentFreeMemorySlot(add(startOfMemory, 0x40)) // advance memory pointer to prepare for loop
                mstore(0, uriLengthSlot())  // store storage slot of uri in memory to get hash
                let startingSlot := keccak256(0, 0x20) // get hash of storage slot

                let slotsAmount := div(stringLength, 0x20) // get amount of storage slots the uri takes up
                // when % 32 is > 1 => add another slot to account for the rest from above or if < 32
                if mod(stringLength, 0x20) {
                    slotsAmount := add(slotsAmount, 1)
                }

                // loop over slots amount and store all parts of the string in memory
                for { let i := 0 } lt(i, slotsAmount) { i := add(i, 1) } {
                    let partialString := sload(safeAdd(startingSlot,i))
                    mstore(currentFreeMemorySlot(), partialString)
                    incrementCurrentFreeMemorySlot()
                }

                returnMemory(startOfMemory, currentFreeMemorySlot())
            }
            
            // ---------------------------------------------------------------- //
            // ------------------------ setURI(string) ------------------------ //
            // same uri for all events. uri url should be parametirzed so clients can change id param inurl to get uri for token id.
            // https://docs.openzeppelin.com/contracts/4.x/api/token/erc1155#ERC1155-_setURI-string-
            // https://docs.openzeppelin.com/contracts/4.x/api/token/erc1155#ERC1155-uri-uint256-
            // https://docs.openzeppelin.com/contracts/4.x/api/token/erc1155#IERC1155-URI-string-uint256-
            // https://eips.ethereum.org/EIPS/eip-1155#metadata
            // ---------------------------------------------------------------- //
            case 0x02fe5305 {
                // get pointer & length of string
                let stringCalldataOffset := decodeAsUint(0)
                let stringLength := calldataloadSkipFnSelector(stringCalldataOffset)

                mstore(0, uriLengthSlot())  // store storage slot of uri in memory to get hash
                let stringStorageSlot := keccak256(0, 0x20) // get hash of storage slot
                
                sstore(uriLengthSlot(), stringLength)  // store string length in uriLengthSlot

                let slotsAmount := div(stringLength, 0x20) // get amount of storage slots the uri takes up
                // when % 32 is >= 1 -> add another slot to account for the rest, or if < 32
                if mod(stringLength, 0x20) {
                    slotsAmount := add(slotsAmount, 1)
                }
                // loop over slots amount and store all parts of the string in memory
                for { let i := 0 } lt(i, slotsAmount) { i := add(i, 1) } {
                    // get calldata at ((i + 1) * 32 bytes) + stringCalldataOffset for each storage slot
                    let partialString := calldataloadSkipFnSelector(add(mul(0x20, add(i, 1)), stringCalldataOffset))
                    // and store at hash of uriLengthSlot => increment for each partial string
                    sstore(add(stringStorageSlot, i), partialString)
                }
            }

            // If no function selector was found we revert (fallback not implemented)
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
            function uriLengthSlot() -> baseSlot { baseSlot := 2 }

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
            // 0x40 - 0x60 => free memory pointer
            // 0x60 - ...  => Free memory
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

                // add lengths of arrays and multiply with 32 bytes, then add 64 bytes for ptrs + lengths
                // => 128 bytes + ((length * 2) * 32 bytes)
                let finalMemorySize := add(0x80, mul(mul(tokenIdsLength, 2), 0x20))

                // start at 0x40 (2pointers) + ((length + 1) * 32 bytes)
                let tokenIdsStart := 0x40
                let amountsStart := add(0x40, mul(add(1, amountsLength), 0x20))

                // store the lengths in their starting postions
                mstore(0x00, tokenIdsStart)           // store 0x40 (pointer of 1st arr starts after the 2 ptrs)
                mstore(0x20, amountsStart)            // store where amounts will start (2nd pointer)
                mstore(tokenIdsStart, tokenIdsLength) // store the length of tokenIds array
                mstore(amountsStart, amountsLength)   // store length of amounts array
                for { let i := 0 } lt(i, tokenIdsLength) { i := add(i, 1) } {
                    // tokenId / amount will be at pointer + (i + 1) then multiply by 32 bytes
                    // so first time => pointer + ((0 + 1) * 32 bytes) and so on
                    let tokenId := calldataloadSkipFnSelector(add(tokenIdsCalldataOffset, mul(add(i, 1), 0x20)))
                    let amount := calldataloadSkipFnSelector(add(amountsCalldataOffset, mul(add(i, 1), 0x20)))
                    
                    // stroe tokenId beginning at 0x60 to account for the 2ptrs + length 1st array
                    mstore(mul(add(i, 3), 0x20), tokenId)
                    mstore(add(amountsStart, mul(add(i, 1), 0x20)), amount)
                }
                log4(0x00, finalMemorySize, signatureHash, operator, from, to)
            }

            function emitApprovalForAll(owner, operator, isApproved) {
                // keccak256 of "ApprovalForAll(address,address,bool)"
                let signatureHash := 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31
                mstore(0, isApproved)
                log3(0, 0x20, signatureHash, owner, operator)
            }

            function emitURI(stringCalldataOffset, id) {
                // keccak256 of "URI(string,uint256)"
                let signatureHash := 0x6bb7ff708619ba0610cba295a58592e0451dee2622938c8755667688daf3529b
                
                // value := sload(slot)
                // Copy the URI value to memory
                // mstore(0x00, value)

                // // Emit URI event
                // log2(0x00, 0x20, signatureHash, id)
            }

            /* -------- HELPER FUNCTIONS FOR CALLDATA DECODING  --------- */
            // @dev grabs the function selector from the calldata
            function getSelector() -> selector {
                selector := shr(224, calldataload(0x00))
            }

            // @dev adds 4 bytes when calldataloading to skip the func selector
            function calldataloadSkipFnSelector(slotWithoutFnSelectorOffset) -> value {
                value := calldataload(add(4, slotWithoutFnSelectorOffset))
            }

            // @dev address is 20 bytes, so we are checking only 20bytes are rpesent in address value, if not revert occurrs.
            function decodeAsAddress(offset) -> value {
                value := decodeAsUint(offset)
                if iszero(iszero(and(value, not(0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff)))) {
                    revert(0, 0)
                }
            }

            // @dev starts at 4th byte to skip function selector and decodes theuint of the calldata
            function decodeAsUint(offset) -> value {
                let pos := add(4, mul(offset, 0x20))
                if lt(calldatasize(), add(pos, 0x20)) {
                    revert(0, 0)
                }
                value := calldataload(pos)
            }

            /* ---------- HELPER FUNCTIONS FOR RETURN DATA ----------- */
            function returnMemory(offset, size) {
                return(offset, size)
            }

            // @dev stores the value in memory 0x00 and returns that part of memory
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
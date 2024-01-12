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

            /* ---------------------------------------------------------- */
            /* --------------------- SETUP STORAGE ---------------------- */
            /* ---------------------------------------------------------- */
            // functions that return the storage slots for readability later on
            function balanceOfMappingSlot() -> p { p := 0 }  // balances of               || address => address => uint256
            function isApprovedForAllMappingSlot() -> p { p := 1 } // approved operators  || address => address => bool
            function uriLengthSlot() -> p { p := 2 } // it stores length of string passed into constructor, next slots => value

            // STORAGE LAYOUT WILL LOOK LIKE THIS
            // 0x00 - 0x20 => Scratch Space
            // 0x20 - 0x40 => Scratch Space
            // 0x40 - 0x60 => Scratch Space
            // 0x60 - 0x80 => Free memory pointer
            // 0x80 - .... => Free memory
            setMemoryPointer(0x80)
            
            /* ------------------------------------------------------- */
            /* ----------------- FUNCTION SELECTORS ------------------ */
            /* ------------------------------------------------------- */

            switch getSelector()
            // -------------------------------------------------------- //
            // --------- mint(address,uint256,uint256,bytes) ---------- //
            // -------------------------------------------------------- //
            case 0x731133e9 {
                let to := decodeAsAddress(0)
                checkForSendingToUnsafeRecipient(to)

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
                let tokenIdsPointer := decodeAsUint(1)      // gets the pointer to the length
                let amountsPointer := decodeAsUint(2)       // gets the pointer to the length
                let tokenIdsLength := calldataloadWith4BytesOffset(tokenIdsPointer) 
                let amountsLength := calldataloadWith4BytesOffset(amountsPointer)


                checkForSendingToUnsafeRecipient(to)

                checkForSameLength(tokenIdsLength, amountsLength)
                
                for { let i := 0 } lt(i, tokenIdsLength) { i := add(i, 1) } {
                    // tokenId will be pointer + (i + 1) and multiply by 32 bytes
                    // by 32 bytes so first time => pointer + ((0 + 1) * 32 bytes) and so on
                    let tokenId := calldataloadWith4BytesOffset(add(tokenIdsPointer, mul(add(i, 1), 0x20)))
                    let amount := calldataloadWith4BytesOffset(add(amountsPointer, mul(add(i, 1), 0x20)))
                    mint(to, tokenId, amount)
                }
                // pass in: operator, from, to, tokenIds, amounts. last two will be handled inside emit function
                emitTransferBatch(caller(), 0, to, tokenIdsPointer, amountsPointer)
            }

            // -------------------------------------------------------- //
            // ------------- balanceOf(address,uint256) --------------- //
            // -------------------------------------------------------- //
            case 0x00fdd58e {
                // puts in the "account" & "tokenId" to get the value and returns the result
                returnUint(getBalanceOfUser(decodeAsAddress(0), decodeAsUint(1)))                      
            }

            // -------------------------------------------------------- //
            // -- balanceOfBatch(address[], uint256[]) -- //
            // -------------------------------------------------------- //
            case 0x4e1273f4 {
                // get pointers where length of arrays are stored
                let ownersPointer := decodeAsUint(0)
                let tokenIdsPointer := decodeAsUint(1)
                let ownersLength := calldataloadWith4BytesOffset(ownersPointer) 
                let tokenIdsLength := calldataloadWith4BytesOffset(tokenIdsPointer)
                
                checkForSameLength(ownersLength, tokenIdsLength)

                // add 32 bytes for length of array then multiply length with 32 bytes
                // => 32 bytes + (length * 32 bytes)
                let finalMemorySize := add(0x40, mul(tokenIdsLength, 0x20))

                // store pointer of array starting at 0x80 (memPointer)
                mstore(getMemoryPointer(), 0x20)
                incrementMemoryPointer()

                // store length of array
                mstore(getMemoryPointer(), tokenIdsLength)
                incrementMemoryPointer()
                
                // loop and get the balances from the given slots & ids and store them
                for { let i := 0 } lt(i, tokenIdsLength) { i := add(i, 1) } {
                    let owner := calldataloadWith4BytesOffset(add(ownersPointer, mul(add(i, 1), 0x20)))
                    let tokenId := calldataloadWith4BytesOffset(add(tokenIdsPointer, mul(add(i, 1), 0x20)))
                    let amount := getBalanceOfUser(owner, tokenId)

                    mstore(getMemoryPointer(), amount)
                    incrementMemoryPointer()
                }
                return(0x80, finalMemorySize)
            }

            // -------------------------------------------------------- //
            // ------------ setApprovalForAll(address,bool) ----------- //
            // -------------------------------------------------------- //
            case 0xa22cb465 {
                let operator := decodeAsAddress(0)
                let isApproved := decodeAsUint(1)
                let slot := getNestedMappingSlot(isApprovedForAllMappingSlot(), caller(), operator)
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


                let fromSlot := getNestedMappingSlot(balanceOfMappingSlot(), from, tokenId)
                let fromBalance := sload(fromSlot)

                // check for sufficient balance, correct to address & approval / ownership 
                checkForSufficientBalance(fromBalance, amount)
                checkForApprovalOfSender(from)
                checkForSendingToUnsafeRecipient(to)

                // already checked for underflow => use sub instead of safeSub
                sstore(fromSlot, sub(fromBalance, amount))

                let toSlot := getNestedMappingSlot(balanceOfMappingSlot(), to, tokenId)
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
                let tokenIdsPointer := decodeAsUint(2)
                let amountsPointer := decodeAsUint(3)
                let tokenIdsLength := calldataloadWith4BytesOffset(tokenIdsPointer) 
                let amountsLength := calldataloadWith4BytesOffset(amountsPointer)

                // check for same length arrays, correct receiver & approval / ownership 
                checkForApprovalOfSender(from)
                checkForSameLength(tokenIdsLength, amountsLength)
                checkForSendingToUnsafeRecipient(to)
                
                // loop and get the balances from the given slots & ids and store them
                for { let i := 0 } lt(i, tokenIdsLength) { i := add(i, 1) } {
                    // get tokenId and amount from calldata
                    let tokenId := calldataloadWith4BytesOffset(add(tokenIdsPointer, mul(add(i, 1), 0x20)))
                    let amount := calldataloadWith4BytesOffset(add(amountsPointer, mul(add(i, 1), 0x20)))
                    // get mapping slots to store the new balances
                    let fromSlot := getNestedMappingSlot(balanceOfMappingSlot(), from, tokenId)
                    let toSlot := getNestedMappingSlot(balanceOfMappingSlot(), to, tokenId)
                    let fromBalance := getBalanceOfUser(from, tokenId)

                    // revert with NOT_ENOUGH_BALANCE => infos for user + underflow protection
                    checkForSufficientBalance(fromBalance, amount)

                    // get oldBalance from slot and safeAdd the amount + overflow protection
                    sstore(fromSlot, sub(sload(fromSlot), amount))
                    sstore(toSlot, safeAdd(sload(toSlot), amount))
                }
                // pass in: operator, from, to, tokenIds, amounts. last two will be handled inside emit function
                emitTransferBatch(caller(), from, to, tokenIdsPointer, amountsPointer)
            }
            
            // ---------------------------------------------------------------- //
            // ------------------------- uri(uint256) ------------------------- //
            // ---------------------------------------------------------------- //
            case 0x0e89341C {
                let stringLength := sload(uriLengthSlot())
                let startOfMemory := getMemoryPointer()
                mstore(startOfMemory, 0x20)  // store pointer to where the string will start
                mstore(add(startOfMemory, 0x20), stringLength) // store string length
                setMemoryPointer(add(startOfMemory, 0x40)) // advance memory pointer to prepare for loop
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
                    mstore(getMemoryPointer(), partialString)
                    incrementMemoryPointer()
                }

                returnMemory(startOfMemory, getMemoryPointer())
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
                let stringPointer := decodeAsUint(0)
                let stringLength := calldataloadWith4BytesOffset(stringPointer)

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
                    // get calldata at ((i + 1) * 32 bytes) + stringPointer for each storage slot
                    let partialString := calldataloadWith4BytesOffset(add(mul(0x20, add(i, 1)), stringPointer))
                    // and store at hash of uriLengthSlot => increment for each partial string
                    sstore(add(stringStorageSlot, i), partialString)
                }
            }

            // If no function selector was found we revert (fallback not implemented)
            default {
                revert(0, 0)
            }

            /* ---------------- FUNCTIONS -------------------------------- */



            /* ---------------------------------------------------------- */
            /* ---------------- FREQUENTLY USED FUNCTIONS --------------- */
            /* ---------------------------------------------------------- */
            function mint(to, tokenId, amount) {
                let slot := getNestedMappingSlot(balanceOfMappingSlot(), to, tokenId)
                // store at balanceSlot (old Balance stored in that slot + amount minted)
                sstore(slot, safeAdd(sload(slot), amount))
            }

            function getBalanceOfUser(account, tokenId) -> balanceOfUser {
                let slot := getNestedMappingSlot(balanceOfMappingSlot(), account, tokenId)
                balanceOfUser := sload(slot)
            }
            
            function isApprovedForAll(account,operator) -> isApproved {
                let slot := getNestedMappingSlot(isApprovedForAllMappingSlot(), account, operator)
                isApproved := sload(slot)
            }

            function checkForSameLength(length1, length2) {
                if iszero(eq(length1, length2)) {
                    // revert with: LENGTH_MISMATCH
                    mstore(0x00, 0x4c454e4754485f4d49534d415443480000000000000000000000000000000000)
                    revert(0x00, 0x20)
                }
            }

            function checkForSendingToUnsafeRecipient(to) {
                if iszero(to) {
                    // revert with: UNSAFE_RECIPIENT
                    mstore(0x00, 0x554e534146455f524543495049454e5400000000000000000000000000000000)
                    revert(0x00, 0x20)
                }
            }

            function checkForApprovalOfSender(from) {
                // check if sender is not the owner or not approved for the "from" address
                if iszero(or(eq(caller(), from), isApprovedForAll(from, caller()))) {
                    // revert with: NOT_AUTHORIZED
                    mstore(0x00, 0x4e4f545f415554484f52495a4544000000000000000000000000000000000000)
                    revert(0x00, 0x20)
                }
            }

            function checkForSufficientBalance(fromBalance, amount) {
                if iszero(gte(fromBalance, amount)) {
                    // revert with: NOT_ENOUGH_BALANCE
                    mstore(0x00, 0x4e4f545f454e4f5547485f42414c414e43450000000000000000000000000000)
                    revert(0x00, 0x20)
                }
            }

            /* ---------------------------------------------------------- */
            /* ---------------- STORAGE HELPER FUNCTIONS ---------------- */
            /* ---------------------------------------------------------- */
            // gets the slot where values are stored in a nested mapping
            function getNestedMappingSlot(mappingSlot, param1, param2) -> slot {
                mstore(0x00, mappingSlot)                       // store storage slot of mapping
                mstore(0x20, param1)                            // store 1st input
                mstore(0x40, param2)                            // store 2nd input

                slot := keccak256(0x00, 0x60)                   // get hash of those => storage slot
            }

            /* ---------------------------------------------------------- */
            /* ---------------- MEMORY HELPER FUNCTIONS ----------------- */
            /* ---------------------------------------------------------- */
            // just returns the memory pointer position which is 0x60
            function getMemoryPointerPosition() -> position {
                position := 0x60
            }

            // gets the value (initialized as 0x80) stored in the memory pointer position 
            function getMemoryPointer() -> value {
                value := mload(getMemoryPointerPosition())
            }

            // advances the memory pointer value by 32 bytes (initialy 0x80 + 0x20 => 0xa0)
            function incrementMemoryPointer() {
                mstore(getMemoryPointerPosition(), add(getMemoryPointer(), 0x20))
            }

            // sets memory pointer to a given memory slot, remember default value is 0x80
            function setMemoryPointer(newSlot) {
                mstore(getMemoryPointerPosition(), newSlot)
            }

            /* ---------------------------------------------------------- */
            /* -------------- EMIT EVENTS HELPER FUNCTIONS -------------- */
            /* ---------------------------------------------------------- */
            function emitTransferSingle(operator, from, to, tokenId, amount) {
                // keccak256 of "TransferSingle(address,address,address,uint256,uint256)"
                let signatureHash := 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62
                // use scratch space to store non indexed values from 0x00 - 0x40
                mstore(0, tokenId)
                mstore(0x20, amount)
                log4(0, 0x40, signatureHash, operator, from, to)
            }

            function emitTransferBatch(operator, from, to, tokenIdsPointer, amountsPointer) {
                // keccak256 of "TransferBatch(address,address,address,uint256[],uint256[])"
                let signatureHash := 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb
                
                let tokenIdsLength := calldataloadWith4BytesOffset(tokenIdsPointer) 
                let amountsLength := calldataloadWith4BytesOffset(amountsPointer)

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
                    let tokenId := calldataloadWith4BytesOffset(add(tokenIdsPointer, mul(add(i, 1), 0x20)))
                    let amount := calldataloadWith4BytesOffset(add(amountsPointer, mul(add(i, 1), 0x20)))
                    
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

            function emitURI(stringPointer, id) {
                // keccak256 of "URI(string,uint256)"
                let signatureHash := 0x6bb7ff708619ba0610cba295a58592e0451dee2622938c8755667688daf3529b
                
                // value := sload(slot)
                // Copy the URI value to memory
                // mstore(0x00, value)

                // // Emit URI event
                // log2(0x00, 0x20, signatureHash, id)
            }

            /* ---------------------------------------------------------- */
            /* -------- HELPER FUNCTIONS FOR CALLDATA DECODING  --------- */
            /* ---------------------------------------------------------- */
            // @dev grabs the function selector from the calldata
            function getSelector() -> selector {
                selector := shr(224, calldataload(0x00))
            }

            // @dev adds 4 bytes when calldataloading to skip the func selector
            function calldataloadWith4BytesOffset(slotWithoutOffset) -> value {
                value := calldataload(add(4, slotWithoutOffset))
            }

            // @dev masks 12 bytes to decode an address from the calldata (address = 20 bytes)
            function decodeAsAddress(offset) -> value {
                value := decodeAsUint(offset)
                if iszero(iszero(and(value, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
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

            /* ------------------------------------------------------- */
            /* ---------- HELPER FUNCTIONS FOR RETURN DATA ----------- */
            /* ------------------------------------------------------- */
            // @dev returns memory data (from offset, size of return value)
            // @param from (starting address in memory) to return, e.g. 0x00
            // @param to (size of the return value), e.g. 0x20 for 32 bytes 0x40 for 64 bytes
            function returnMemory(offset, size) {
                return(offset, size)
            }

            // @dev stores the value in memory 0x00 and returns that part of memory
            function returnUint(v) {
                mstore(0, v)
                return(0, 0x20)
            }

            /* ------------------------------------------------------- */
            /* -------------- UTILITY HELPER FUNCTIONS --------------- */
            /* ------------------------------------------------------- */
            function lte(a, b) -> r {
                r := iszero(gt(a, b))
            }

            function gte(a, b) -> r {
                r := iszero(lt(a, b))
            }

            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }

            // Overflow & Underflow Protection / Safe Math 
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
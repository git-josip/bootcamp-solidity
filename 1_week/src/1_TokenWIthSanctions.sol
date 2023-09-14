// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {ERC1363} from "@payabletoken/contracts/token/ERC1363/ERC1363.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title ERC1363 fungible token which implements addresses sanctioning
 * @author Josip Medic
 * @notice Address sanctions
 *
 */
contract TokenWithSanctions is ERC1363, Ownable {
    using SafeERC20 for ERC20;

    mapping(address => bool) private sanctionedAddresses;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) Ownable() {}

    /**
     * @notice Add sanction for provided address from making any transfers or recieve tokens
     * @dev Only owner is allowed to call this function
     * @param _address which will be sanctioned
     */
    function addSanctionForAddress(address _address) external onlyOwner {
        require(_address != address(0));

        sanctionedAddresses[_address] = true;
    }

    /**
     * @notice Remove sanction for provided address from making any transfers or recieve tokens
     * @dev Only owner is allowed to call this function
     * @param _address which sanction will be removed
     */
    function removeSanctionForAddress(address _address) external onlyOwner {
        require(_address != address(0));

        delete sanctionedAddresses[_address];
    }

    /**
     * @notice Info about is address sanctioned or not
     * @param _address for which it will be chdck is it sanctioned
     */
    function isAddressSanctioned(address _address) external view returns (bool isSanctioned) {
        isSanctioned = sanctionedAddresses[_address];
    }

    /**
     * @notice hook which is executed before any token transfer.
     * @param from address which is sending tokens
     * @param to address which is receiving tokens
     * @param amount amount of tokens to be sent
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20) {
        super._beforeTokenTransfer(from, to, amount);

        require(sanctionedAddresses[from] == false, "Address from is sanctioned.");
        require(sanctionedAddresses[to] == false, "Address to is sanctioned.");
    }
}

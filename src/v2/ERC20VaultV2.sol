// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20Vault} from "../v1/ERC20Vault.sol";

contract ERC20VaultV2 is ERC20Vault {
    constructor() {
        _disableInitializers();
    }

    /// @notice reward rate increased 2x
    /// @param timeStaked a parameter just like in doxygen (must be followed by parameter name)
    /// @param shares shares calculated
    /// @return Calculate the extra reward
    /// @inheritdoc	ERC20Vault
    function _calculateExtraReward(uint256 timeStaked, uint256 shares) internal pure override returns (uint256) {
        return (shares * timeStaked) / 1800;
    }

    function _authorizeUpgrade(address _newImplementation) internal override onlyOwner {}
}

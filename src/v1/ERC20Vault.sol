// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title ERC20Vault with Universal upgradeable proxy standard
 * @author hackFlu
 * @notice a simple contract with secuirty feature
 */
contract ERC20Vault is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /*//////////////////////////////////////////////////////////////
                            TYPE DECLERATION
    //////////////////////////////////////////////////////////////*/
    struct UserInfo {
        uint256 balances;
        uint256 lastUpdatedTime;
    }

    struct VaultStorage {
        IERC20 token;
        uint256 totalAssets;
        mapping(address => UserInfo) userInfos;
        uint256 totalShares;
        uint256 rewardPerTokenStored;
    }

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event DepositSuccessful(address indexed user, uint256 amount);
    event WithdrawlSuccessful(address indexed user, uint256 assetToReturn, uint256 rewardAmount);
    event ClaimSuccessful(address indexed user, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                                  ERROR
    //////////////////////////////////////////////////////////////*/
    error ERC20Vault__AddressZero();
    error ERC20Vault__AtleastOneEth();
    error ERC20Vault__SharesOverFlow();
    error ERC20Vault__NativeEthTransactionFailed();

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor() {
        _disableInitializers();
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTION
    //////////////////////////////////////////////////////////////*/
    /// @notice user deposit the native eth
    /// @dev Emit an event DepositSuccessful.
    function deposit() external payable {
        // check
        if (msg.sender == address(0)) {
            revert ERC20Vault__AddressZero();
        }
        if (msg.value == 0) {
            revert ERC20Vault__AtleastOneEth();
        }
        // Effect
        _setDepositAndTransfer(msg.sender, msg.value);
        emit DepositSuccessful(msg.sender, msg.value);
    }

    /// @notice withdraw amount with reward.
    /// @dev emits an event WithdrawlSuccessful.
    /// @param sharesToBurn a parameter to insert amount to withdraw.
    function withdraw(uint256 sharesToBurn) external {
        VaultStorage storage vault = _getStorageLocation();
        uint256 totalShare = vault.totalShares;
        uint256 totalAssets = vault.totalAssets;
        UserInfo storage userInfo = vault.userInfos[msg.sender];
        // check
        if (sharesToBurn > userInfo.balances) {
            revert ERC20Vault__SharesOverFlow();
        }

        // effect
        uint256 assetsToReturn = (sharesToBurn * totalAssets) / totalShare;
        uint256 rewardAmount = _calculateExtraReward(userInfo.lastUpdatedTime, sharesToBurn);

        vault.totalShares = totalShare - sharesToBurn;
        vault.totalAssets = totalAssets - assetsToReturn;
        uint256 sharesToBurnFromUser = userInfo.balances - sharesToBurn;
        userInfo.balances = sharesToBurnFromUser;
        userInfo.lastUpdatedTime = block.timestamp;

        // interaction
        (bool success,) = payable(msg.sender).call{value: assetsToReturn}("");
        if (!success) {
            revert ERC20Vault__NativeEthTransactionFailed();
        }
        vault.token.transfer(msg.sender, rewardAmount);
        emit WithdrawlSuccessful(msg.sender, assetsToReturn, rewardAmount);
    }

    /*//////////////////////////////////////////////////////////////
                             PUBLIC FUNCTION
    //////////////////////////////////////////////////////////////*/
    function initialize(address token, uint256 rewardPerTokenStored) public initializer {
        __Ownable_init(msg.sender);
        VaultStorage storage vault = _getStorageLocation();
        vault.token = IERC20(token);
        vault.totalAssets = 0;
        vault.rewardPerTokenStored = rewardPerTokenStored;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTION
    //////////////////////////////////////////////////////////////*/
    /// @custom:storage-location erc7201:ERC20Vault.storage.main
    function _internalSlotLocation() internal pure returns (bytes32) {
        return 0x89e4a766281ae1b2ba7258575ff0092717fad3568422663a082821937e6c1100;
    }

    function _getStorageLocation() internal pure returns (VaultStorage storage vault) {
        bytes32 slot = _internalSlotLocation();
        assembly {
            vault.slot := slot
        }
    }

    function _convertToShare(uint256 assets, uint256 supply, uint256 pool) internal pure returns (uint256) {
        if (supply == 0) {
            return assets;
        }
        uint256 totalShare = (assets * (supply + 1)) / (pool + 1);
        return totalShare;
    }

    function _calculateExtraReward(uint256 timeStaked, uint256 shares) internal pure virtual returns (uint256) {
        return (shares * timeStaked) / 3600;
    }

    function _setDepositAndTransfer(address user, uint256 assetDepoisted) internal {
        VaultStorage storage vault = _getStorageLocation();
        uint256 totalShare = vault.totalShares;
        uint256 totalAssets = vault.totalAssets;
        uint256 share = _convertToShare(assetDepoisted, totalShare, totalAssets);

        vault.totalAssets = totalAssets + assetDepoisted;
        vault.totalShares = totalShare + share;

        UserInfo storage userInfo = vault.userInfos[user];
        userInfo.balances += share;
        userInfo.lastUpdatedTime = block.timestamp;
    }

    function _authorizeUpgrade(address _newImplementation) internal virtual override onlyOwner {}
}

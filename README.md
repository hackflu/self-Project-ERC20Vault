# ERC20 Vault with UUPS Upgradeability

This project implements an upgradeable ERC20 Vault that allows users to deposit native Ether and earn rewards in a custom ERC20 `RewardToken`. The vault is designed with upgradeability in mind, utilizing OpenZeppelin's UUPS (Universal Upgradeable Proxy Standard) pattern. It showcases a V1 and a V2 implementation of the vault, demonstrating a seamless upgrade process.

## Features

- **Native ETH Deposit**: Users can deposit native Ether into the vault.
- **Reward Mechanism**: Depositors receive a custom `RewardToken` based on their staked amount and time.
- **UUPS Upgradeability**: The vault's logic can be upgraded to new versions without changing the contract address, ensuring continuity and future-proofing.
- **V1 and V2 Implementations**:
    - `ERC20Vault.sol` (V1): The initial implementation of the vault.
    - `ERC20VaultV2.sol` (V2): An upgraded version that, for example, doubles the reward rate (`_calculateExtraReward`).
- **Owner-Controlled**: Key administrative functions, such as `mintToken` for the `RewardToken` and `_authorizeUpgrade` for the vault, are restricted to the contract owner.
- **Error Handling**: Custom errors are implemented for clearer feedback on failed operations.

## Technologies Used

- **Solidity**: Smart contract language.
- **Foundry**: Development framework for testing, deploying, and interacting with smart contracts.
- **OpenZeppelin Contracts**: Industry-standard library for secure smart contract development, providing implementations for ERC20, Ownable, UUPSUpgradeable, and ERC1967Proxy.

## Project Structure

The project is organized as follows:

```
.
├── lib/                            # Third-party libraries (OpenZeppelin, forge-std, foundry-devops)
├── script/
│   ├── DeployImplementaionV1.s.sol # Foundry script to deploy V1 of the vault and RewardToken
│   └── DeployImplementationV2.s.sol# Foundry script to upgrade the vault to V2
├── src/
│   ├── v1/
│   │   └── ERC20Vault.sol          # Version 1 of the ERC20 Vault contract
│   ├── v2/
│   │   └── ERC20VaultV2.sol        # Version 2 of the ERC20 Vault contract (upgraded logic)
│   └── RewardToken.sol             # Custom ERC20 token used for rewards
└── test/
    ├── integration/
    │   ├── DeployScriptTestV1.t.sol# Integration test for V1 deployment script
    │   └── DeployScriptTestV2.t.sol# Integration test for V2 upgrade script
    └── unit/
        ├── ERC20VaultTest.t.sol    # Unit tests for ERC20Vault (V1) functionalities
        ├── RewardTokenTest.t.sol   # Unit tests for RewardToken
        ├── Upgradation.t.sol       # Unit test for the upgrade process (basic)
        └── UpgradationTest.t.sol   # Unit test for the upgrade process (with deposit/withdraw)
```

## Setup and Installation

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd self-Project-ERC20
    ```

2.  **Install Foundry**: If you don't have Foundry installed, follow the instructions here.

3.  **Install dependencies**:
    ```bash
    forge install
    ```

## Usage

### Deploying V1

To deploy the initial version of the `ERC20Vault` and `RewardToken` using the Foundry script:

```bash
forge script script/DeployImplementaionV1.s.sol --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast
```

### Upgrading to V2

To upgrade the deployed `ERC20Vault` to `ERC20VaultV2`:

```bash
forge script script/DeployImplementationV2.s.sol --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast --sig "run(address)" <OWNER_ADDRESS>
```
Replace `<OWNER_ADDRESS>` with the address that owns the proxy (initially the deployer of V1).

### Running Tests

To run all unit and integration tests:

```bash
forge test -vvv
```

## Contracts

- **`ERC20Vault.sol`**: The core vault contract (V1) handling deposits, withdrawals, and reward calculation.
- **`ERC20VaultV2.sol`**: The upgraded vault contract (V2) with modified reward calculation logic.
- **`RewardToken.sol`**: A simple ERC20 token used to distribute rewards to vault depositors.
- **`ERC1967Proxy.sol`**: OpenZeppelin's proxy contract that delegates calls to the current implementation.

## Security Considerations

This project uses OpenZeppelin's battle-tested upgradeable contracts. However, any custom logic, especially in `_calculateExtraReward` or `_authorizeUpgrade`, should be thoroughly audited. The `_authorizeUpgrade` function in `ERC20VaultV2` is currently empty, meaning only the owner can trigger an upgrade, which is a standard and secure practice.
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {ERC20Vault} from "../src/v1/ERC20Vault.sol";
import {ERC20VaultV2} from "../src/v2/ERC20VaultV2.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract UpgradeImplementationV2 is Script {
    function run() public returns(address){
        address mostRecentAddress = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
        vm.startBroadcast();
        ERC20VaultV2 upgradedVault = new ERC20VaultV2();
        address proxies = UpgradeImplementationV1(mostRecentAddress, address(upgradedVault));
        vm.stopBroadcast();
    }

    function UpgradeImplementationV1(address proxyAddress, address _newImplementationV2) public returns (address) {
        ERC20Vault proxy = ERC20Vault(payable(proxyAddress));
        proxy.upgradeToAndCall(_newImplementationV2, "");
        return address(proxy);
    }
}

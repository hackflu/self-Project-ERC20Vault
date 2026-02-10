// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {ERC20Vault} from "../src/ERC20Vault.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {
    ERC1967Proxy
} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployImplementationV1 is Script {
    function run() public returns (ERC20Vault, RewardToken, ERC1967Proxy) {
        vm.startBroadcast();
        (ERC20Vault vault, RewardToken token, ERC1967Proxy proxy) = deployCode();
        vm.stopBroadcast();
    }

    function deployCode()
        public
        returns (ERC20Vault, RewardToken, ERC1967Proxy)
    {
        ERC20Vault vault = new ERC20Vault();
        RewardToken rewardToken = new RewardToken();

        ERC1967Proxy proxy = new ERC1967Proxy(address(vault), "");
        ERC20Vault(address(proxy)).initialize(address(rewardToken), 10);
        rewardToken.mintToken(address(proxy), rewardToken.getFixedSupply());
        return (vault, rewardToken, proxy);
    }
}

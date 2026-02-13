// SPDX-License-Identifier: MIT
import {Test, console} from "forge-std/Test.sol";
import {ERC20Vault} from "../../src/v1/ERC20Vault.sol";
import {ERC20VaultV2} from "../../src/v2/ERC20VaultV2.sol";
import {DeployImplementationV1} from "../../script/DeployImplementaionV1.s.sol";
import {UpgradeImplementationV2} from "../../script/DeployImplementationV2.s.sol";
import {RewardToken} from "../../src/RewardToken.sol";
import {
    ERC1967Proxy
} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract ERC20VaultTestV2 is Test {
    ERC20Vault public vault;
    ERC20VaultV2 public upgradedVault;
    RewardToken public rewardToken;
    DeployImplementationV1 public deployScript;
    UpgradeImplementationV2 public deployScriptForUpgrade;
    ERC1967Proxy public proxy;

    address public owner = makeAddr("owner");

    function setUp() public {
        deployScript = new DeployImplementationV1();
        (vault, rewardToken, proxy) = deployScript.deployCode();
        console.log("address proxy : ", address(proxy));
        console.log("owner of ERC20vault : ", ERC20Vault(address(proxy)).owner());
        deployScriptForUpgrade = new UpgradeImplementationV2();
        upgradedVault = new ERC20VaultV2();
        console.log("owner of deployScript : ", ERC20VaultV2(address(proxy)).owner());
    }

    function testUpgrade() public {
        vm.prank(ERC20Vault(address(proxy)).owner());
        ERC20Vault(address(proxy)).transferOwnership(address(deployScriptForUpgrade));
        vm.prank(address(deployScriptForUpgrade));
        address proxies = deployScriptForUpgrade.UpgradeImplementationV1(address(proxy), address(upgradedVault));
        console.log("owner of deployScript : ", ERC20VaultV2(address(proxy)).owner());
        assertEq(ERC20VaultV2(address(proxy)).owner(), address(deployScriptForUpgrade));
        assertEq(proxies, address(proxy));
    }
}


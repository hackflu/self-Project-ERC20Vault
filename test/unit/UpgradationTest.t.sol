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
    ERC20VaultV2 public upgradedVault;
    RewardToken public rewardToken;
    DeployImplementationV1 public deployScript;
    UpgradeImplementationV2 public deployScriptForUpgrade;
    ERC1967Proxy public proxy;

    address public alice = makeAddr("alice");
    address public sia = makeAddr("sia");

    function setUp() public {
        deployScript = new DeployImplementationV1();
        (, rewardToken, proxy) = deployScript.deployCode();
        console.log("address proxy : ", address(proxy));
        console.log("owner of ERC20vault : ", ERC20Vault(address(proxy)).owner());
        deployScriptForUpgrade = new UpgradeImplementationV2();
        upgradedVault = new ERC20VaultV2();
        console.log("owner of deployScript : ", ERC20VaultV2(address(proxy)).owner());
    }

    modifier requiredToDepositAndWithdrawl() {
        vm.deal(alice, 1 ether);
        vm.startPrank(alice);
        ERC20Vault(address(proxy)).deposit{value: 1 ether}();
        vm.warp(1 days);
        ERC20Vault(address(proxy)).withdraw(1e18);

        vm.stopPrank();
        console.log("alice balance : ", alice.balance);
        console.log("reward token balance : ", rewardToken.balanceOf(alice));
        _;
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

    /**
     * @notice to check the upgraded _calculateReward function
     */
    function testCalculateReward() public requiredToDepositAndWithdrawl{

        // 1. upgrade the code
        vm.prank(ERC20Vault(address(proxy)).owner());
        ERC20Vault(address(proxy)).transferOwnership(address(deployScriptForUpgrade));
        vm.prank(address(deployScriptForUpgrade));
        address proxies = deployScriptForUpgrade.UpgradeImplementationV1(address(proxy), address(upgradedVault));

        //3. another deposit (SIA)
        vm.deal(sia , 1 ether);
        vm.startPrank(sia);
        ERC20VaultV2(address(proxies)).deposit{value: 1 ether}();
        vm.warp(1 days);
        ERC20VaultV2(address(proxies)).withdraw(1e18);
        vm.stopPrank();
        console.log("sia balance : ", sia.balance);
        console.log("reward token of sia balance : ", rewardToken.balanceOf(sia));
        assertGe(rewardToken.balanceOf(sia),rewardToken.balanceOf(alice));
    }
}


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {ERC20Vault} from "../../src/ERC20Vault.sol";
import {RewardToken} from "../../src/RewardToken.sol";
import {DeployImplementationV1} from "../../script/DeployImplementaionV1.s.sol";
import {
    ERC1967Proxy
} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Vm} from "forge-std/Vm.sol";

contract ERC20VaultTest is Test {
    ERC20Vault public vault;
    RewardToken public rewardToken;
    DeployImplementationV1 public deployScript;
    ERC1967Proxy public proxy;
    address public owner = makeAddr("owner");
    address public alice = makeAddr("alice");

    function setUp() public {
        vm.prank(owner);
        deployScript = new DeployImplementationV1();
        (vault, rewardToken, proxy) = deployScript.deployCode();
    }

    /*//////////////////////////////////////////////////////////////
                            DEPOSIT FUNCTION
    //////////////////////////////////////////////////////////////*/

    function testDeposit() public {
        vm.deal(alice, 10 ether);
        console.log(rewardToken.balanceOf(address(proxy)));
        vm.prank(alice);
        ERC20Vault(address(proxy)).deposit{value: 1 ether}();
        assertEq(address(proxy).balance,  1e18);
    }

    function testDepositWithEvent() public {
        vm.deal(alice, 10 ether);
        vm.startPrank(alice);
        vm.recordLogs();
        ERC20Vault(address(proxy)).deposit{value: 1 ether}();
        Vm.Log[] memory logs = vm.getRecordedLogs();
        vm.stopPrank();
        bytes32 aliceInBytes32 = bytes32(uint256(uint160(alice)));
        assertEq(logs[0].topics[1], aliceInBytes32);
        assertEq(logs[0].data, abi.encode(1e18));
        assertEq(logs.length, 1);
    }

    modifier requiredToDeposit() {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        ERC20Vault(address(proxy)).deposit{value: 1 ether}();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                        WITHDRAWL FUNCTION
    //////////////////////////////////////////////////////////////*/

    function testWithdrawl() public requiredToDeposit {
        vm.startPrank(alice);
        console.log("reward token before : ", rewardToken.balanceOf(alice));

        ERC20Vault(address(proxy)).withdraw(1e18);
        console.log("alice balnce : ", alice.balance);
        console.log("reward token after : ", rewardToken.balanceOf(alice));
        vm.stopPrank();


        // assertEq(rewardToken.balanceOf(alice) ,  277777777777777);
    }
}

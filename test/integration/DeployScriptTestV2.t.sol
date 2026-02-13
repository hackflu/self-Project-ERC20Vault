// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {UpgradeImplementationV2} from "../../script/DeployImplementationV2.s.sol";

contract DeployScriptTestV2 is Test {
    UpgradeImplementationV2 deployScript;

    function setUp() public {
        deployScript = new UpgradeImplementationV2();
    }

    function testDeployV2() public {
        address proxies = deployScript.run(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        vm.stopPrank();
        console.log("proxy address : ", address(proxies));
    }
}

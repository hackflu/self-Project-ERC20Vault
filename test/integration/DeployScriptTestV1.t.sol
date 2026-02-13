// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {DeployImplementationV1} from "../../script/DeployImplementaionV1.s.sol";
import {Test,console} from "forge-std/Test.sol";
import {
    ERC1967Proxy
} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
contract Integeration is Test {
    DeployImplementationV1 deployScript;
    function setUp() public {
        deployScript = new DeployImplementationV1();
    }
    function testDeploy() public {
        (, , ERC1967Proxy proxy) = deployScript.run();
        console.log("proxy address : ",address(proxy));    
    }
}
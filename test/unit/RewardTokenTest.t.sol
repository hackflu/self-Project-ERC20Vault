// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {RewardToken} from "../../src/RewardToken.sol";
import {Test} from "forge-std/Test.sol";

contract RewardTokenTest is Test {
    RewardToken rewardToken;
    function setUp() public {
        rewardToken = new RewardToken();
    }

    function testMintToken() public {
        rewardToken.mintToken(address(this), 100 ether);
        assertEq(rewardToken.balanceOf(address(this)), 100 ether);
        assertEq(rewardToken.getTotalMintedToken(), 100 ether);
        assertEq(rewardToken.getFixedSupply(), 100_000_000 ether);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20, Ownable {
    /*//////////////////////////////////////////////////////////////
                             STATE VARIABLE
    //////////////////////////////////////////////////////////////*/
    uint256 private alreadyMinted;
    uint256 private constant fixedSupply = 100_000_000 ether;

    /*//////////////////////////////////////////////////////////////
                                  ERROR
    //////////////////////////////////////////////////////////////*/
    error RewardToken__Overflow();

    /*//////////////////////////////////////////////////////////////
                                FUNCTION
    //////////////////////////////////////////////////////////////*/
    constructor() ERC20("RewardToken", "RT") Ownable(msg.sender) {}

    function mintToken(address to, uint256 amount) external onlyOwner {
        if (alreadyMinted + amount > fixedSupply) {
            revert RewardToken__Overflow();
        }
        alreadyMinted += amount;
        _mint(to, amount);
    }

    /*//////////////////////////////////////////////////////////////
                             PUBLIC FUNCTION
    //////////////////////////////////////////////////////////////*/
    function getTotalMintedToken() public view returns (uint256) {
        return alreadyMinted;
    }

    function getFixedSupply() public pure returns (uint256) {
        return fixedSupply;
    }
}

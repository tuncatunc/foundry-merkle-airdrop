// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// contract BigganosToken is ERC20, Ownable {
//     constructor() ERC20("Bigganos Token", "BIG") Ownable(msg.sender) {}

//     function mint(address to, uint256 amount) external onlyOwner {
//         _mint(to, amount);
//     }
// }

contract BigganosToken is ERC20, Ownable {
    uint256 public constant TOTAL_SUPPLY = 100_000_000 ether;
    uint256 public constant CONTRACTORS_ALLOCATION = 20_000_000 ether;
    uint256 public constant CODESTUDIO_ALLOCATION = 5_000_000 ether;
    uint256 public constant PUBLIC_ALLOCATION = 5_000_000 ether;
    uint256 public constant PARKSTONE_ALLOCATION = 2_500_000 ether;
    uint256 public constant BIG_ALLOCATION = 67_500_000 ether;

    address public contractorsWallet;
    address public codeStudioWallet;
    address public publicWallet;
    address public parkstoneWallet;
    address public bigWallet;

    constructor(
        address _contractorsWallet,
        address _codeStudioWallet,
        address _publicWallet,
        address _parkstoneWallet,
        address _bigWallet
    ) ERC20("Bigganos Token", "BIG") Ownable(msg.sender) {
        contractorsWallet = _contractorsWallet;
        codeStudioWallet = _codeStudioWallet;
        publicWallet = _publicWallet;
        parkstoneWallet = _parkstoneWallet;
        bigWallet = _bigWallet;

        _mint(contractorsWallet, CONTRACTORS_ALLOCATION);
        _mint(codeStudioWallet, CODESTUDIO_ALLOCATION);
        _mint(publicWallet, PUBLIC_ALLOCATION);
        _mint(parkstoneWallet, PARKSTONE_ALLOCATION);
        _mint(bigWallet, BIG_ALLOCATION);
    }

    // Additional functions for vesting, airdrops, and redistribution can be implemented here
}

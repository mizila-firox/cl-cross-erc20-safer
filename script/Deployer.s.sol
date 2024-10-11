// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {BurnMintERC677} from "lib/chainlink-local/lib/ccip/contracts/src/v0.8/shared/token/ERC677/BurnMintERC677.sol";
import {Sender} from "../src/Sender.sol";
import {Receiver} from "../src/Receiver.sol";

contract DeployerScript is Script {
    //
    address fuji = 0x75F53657dfE91c4d1C2729880CA279F890488De0;
    address sepolia = 0xC0C6Ad956DF411251431eA139fAEa3a634D99C26;

    function run() external {
        vm.startBroadcast();
        IERC20 linkToken = IERC20(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846); // link fuji
        BurnMintERC677 tokenBnM = BurnMintERC677(
            0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4
        );

        // SEPOLIA
        // Receiver receiver = new Receiver();
        // console.log(address(receiver));

        // FUJI
        // Sender sender = new Sender();
        // console.log(address(sender));

        // Sender sender = Sender(fuji);

        // linkToken.transfer(fuji, 5 ether);
        // tokenBnM.transfer(fuji, 0.012 ether);

        // console.log(linkToken.balanceOf(fuji));
        // console.log(tokenBnM.balanceOf(fuji));
        // bytes32 receipt = sender.sendMessage(sepolia, 0.012 ether, msg.sender);
        // console.logBytes32(receipt);

        // SEPOLIA - allowing for fuji contract and fuji chain to send data there
        Receiver receiver = Receiver(sepolia);

        // this should fail, because it calls directly from the chain
        receiver.foo(msg.sender, 0.01 ether, fuji, 14767482510784806043);

        //     function foo(
        //     address _sender,
        //     uint256 _amount,
        //     address _contractAddress,
        //     uint64 _sourceChainSelector
        // )

        // console.log(receiver.balances(msg.sender));

        // receiver.setAllowedChain(14767482510784806043, true); // fuji chain TRUE
        // receiver.setAllowedContract(fuji, true); // sender contract TRUE
        // console.log(receiver.allowedChains(14767482510784806043)); // fuji chain
        // console.log(receiver.allowedContracts(fuji)); // sender contract
    }
}

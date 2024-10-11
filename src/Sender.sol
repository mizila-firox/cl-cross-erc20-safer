// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IRouterClient} from "lib/chainlink-local/lib/ccip/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "lib/chainlink-local/lib/ccip/contracts/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {BurnMintERC677} from "lib/chainlink-local/lib/ccip/contracts/src/v0.8/shared/token/ERC677/BurnMintERC677.sol";

//  fuji -> sepolia
contract Sender {
    IRouterClient public router =
        IRouterClient(0xF694E193200268f9a4868e4Aa017A0118C9a8177); // router fuji
    uint64 destinationChain = 16015286601757825753;
    uint64 sourceChainSelector = 14767482510784806043;
    IERC20 linkToken = IERC20(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846); // link fuji
    BurnMintERC677 tokenBnM =
        BurnMintERC677(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4);
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function sendMessage(
        address _receiverAddr,
        uint256 _tokenAmount,
        address _owner
    ) external returns (bytes32 receipt) {
        Client.EVMTokenAmount[] memory tokens = new Client.EVMTokenAmount[](1);

        tokens[0] = Client.EVMTokenAmount({
            token: address(tokenBnM),
            amount: _tokenAmount
        });

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiverAddr),
            data: abi.encodeWithSignature(
                "foo(address,uint256,address,uint64)",
                _owner,
                _tokenAmount,
                address(this),
                sourceChainSelector
            ),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 950_000})
            ),
            tokenAmounts: tokens,
            feeToken: address(linkToken)
        });

        uint256 ccipFee = router.getFee(destinationChain, message);

        if (ccipFee > linkToken.balanceOf(address(this))) {
            revert("Insufficient fee token amountt");
        }

        // tokenBnM.increaseApproval(address(router), _tokenAmount);
        linkToken.approve(address(router), ccipFee);
        tokenBnM.approve(address(router), _tokenAmount);

        receipt = router.ccipSend(destinationChain, message);
    }

    // enable receivers
}

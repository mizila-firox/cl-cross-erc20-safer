// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {CCIPReceiver} from "lib/chainlink-local/lib/ccip/contracts/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "lib/chainlink-local/lib/ccip/contracts/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

contract Receiver is CCIPReceiver {
    address router = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59; // sepolia router
    address public owner;
    bool public working;
    uint64 public lastChainSelector;

    mapping(address => uint) public balances;
    mapping(uint64 => bool) public allowedChains;
    mapping(address => bool) public allowedContracts;

    function setAllowedChain(uint64 _chainSelector, bool _allowed) external {
        require(
            owner == msg.sender,
            "Receiver: only owner can set allowed chains"
        );
        allowedChains[_chainSelector] = _allowed;
    }

    function setAllowedContract(address _contract, bool _allowed) external {
        require(
            owner == msg.sender,
            "Receiver: only owner can set allowed contracts"
        );
        allowedContracts[_contract] = _allowed;
    }

    event AmountTransfered(
        uint256 chainSelector,
        address sender,
        uint256 amount,
        uint64 sourceChainSelector
    );

    constructor() CCIPReceiver(router) {
        owner = msg.sender;
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        lastChainSelector = message.sourceChainSelector;
        // bytes memory data = abi.encode(message.data);
        (bool success, ) = address(this).call(message.data);
        require(success, "Receiver: call failed");
    }

    function foo(
        address _sender,
        uint256 _amount,
        address _contractAddress,
        uint64 _sourceChainSelector
    )
        external
        allowedChainsSelector(_sourceChainSelector)
        onlyAllowedContracts(_contractAddress)
        onlyCallableBySelf
    {
        balances[_sender] += _amount;
        emit AmountTransfered(
            lastChainSelector,
            _contractAddress,
            _amount,
            _sourceChainSelector
        );
        lastChainSelector = 0;
    }

    modifier onlyCallableBySelf() {
        require(msg.sender == address(this), "Receiver: only callable by self");
        _;
    }

    modifier onlyAllowedContracts(address _contractAddress) {
        require(
            allowedContracts[_contractAddress],
            "Receiver: contract not allowed"
        );
        _;
    }

    modifier allowedChainsSelector(uint64 _sourceChainSelector) {
        require(
            allowedChains[_sourceChainSelector],
            "Receiver: chain not allowed"
        );
        _;
    }

    function withdraw(address _tokenAddr, uint256 _amount) external {
        IERC20 token = IERC20(_tokenAddr);
        require(
            token.balanceOf(address(this)) >= _amount,
            "Receiver: insufficient balance"
        );

        token.transfer(msg.sender, _amount);
    }
}

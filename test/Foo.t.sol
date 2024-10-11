// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ERC20} from "lib/chainlink-local/lib/chainlink-brownie-contracts/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/ERC20.sol";

// just testing a concept here, ignore it
contract Foo is Test {
    function testFoo() external {
        Baz baz = new Baz();
        Bar bar = new Bar();

        baz.transfer(address(bar), 1 ether);
        assertEq(baz.balanceOf(address(bar)), 1 ether);
    }
}

contract Bar {}

contract Baz is ERC20 {
    constructor() ERC20("Baz", "BZ") {
        _mint(msg.sender, 1000 ether);
    }
}

pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./GebSfTreasuryAllowanceReseter.sol";

contract GebSfTreasuryAllowanceReseterTest is DSTest {
    GebSfTreasuryAllowanceReseter reseter;

    function setUp() public {
        reseter = new GebSfTreasuryAllowanceReseter();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}

pragma solidity 0.6.7;

import "ds-test/test.sol";
import "geb/StabilityFeeTreasury.sol";
import "geb/SAFEEngine.sol";
import "geb/Coin.sol";
import {CoinJoin} from "geb/BasicTokenAdapters.sol";

import "../SFTreasuryAllowanceReseter.sol";

abstract contract Hevm {
    function warp(uint256) virtual public;
}
contract SFTreasuryAllowanceReseterTest is DSTest {
    Hevm hevm;

    SFTreasuryAllowanceReseter treasuryReseter;
    SAFEEngine safeEngine;
    Coin coin;
    CoinJoin coinJoin;
    StabilityFeeTreasury treasury;

    function setUp() public {
        hevm = Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        hevm.warp(604411200);

        safeEngine      = new SAFEEngine();
        coin            = new Coin("RAI", "RAI", 99);
        coinJoin        = new CoinJoin(address(safeEngine), address(coin));
        treasury        = new StabilityFeeTreasury(address(safeEngine), address(0x2), address(coinJoin));
        treasuryReseter = new SFTreasuryAllowanceReseter(address(treasury));

        treasury.addAuthorization(address(treasuryReseter));
    }

    function test_setup() public {
        assertEq(address(treasuryReseter.treasury()), address(treasury));
    }
    function testFail_reset_when_per_block_null_total_null() public {
        treasuryReseter.resetTotalAllowance(address(0x3));
    }
    function test_reset_when_per_block_tiny_total_null() public {
        treasury.setPerBlockAllowance(address(0x3), 1);
        treasuryReseter.resetTotalAllowance(address(0x3));

        (uint totalAllowance, uint perBlockAllowance) = treasury.getAllowance(address(0x3));
        assertEq(totalAllowance, uint(-1));
        assertEq(perBlockAllowance, 1);
    }
    function test_reset_when_per_block_max_total_null() public {
        treasury.setPerBlockAllowance(address(0x3), uint(-1));
        treasuryReseter.resetTotalAllowance(address(0x3));

        (uint totalAllowance, uint perBlockAllowance) = treasury.getAllowance(address(0x3));
        assertEq(totalAllowance, uint(-1));
        assertEq(perBlockAllowance, uint(-1));
    }
    function test_reset_when_per_block_normal_total_null() public {
        treasury.setPerBlockAllowance(address(0x3), 1E18);
        treasuryReseter.resetTotalAllowance(address(0x3));

        (uint totalAllowance, uint perBlockAllowance) = treasury.getAllowance(address(0x3));
        assertEq(totalAllowance, uint(-1));
        assertEq(perBlockAllowance, 1E18);
    }
    function testFail_reset_when_per_block_null_total_positive() public {
        treasury.setTotalAllowance(address(0x3), 1E18);
        treasuryReseter.resetTotalAllowance(address(0x3));
    }
    function test_reset_when_per_block_tiny_total_positive() public {
        treasury.setTotalAllowance(address(0x3), 1E18);
        treasury.setPerBlockAllowance(address(0x3), 1);
        treasuryReseter.resetTotalAllowance(address(0x3));

        (uint totalAllowance, uint perBlockAllowance) = treasury.getAllowance(address(0x3));
        assertEq(totalAllowance, uint(-1));
        assertEq(perBlockAllowance, 1);
    }
    function test_reset_when_per_block_max_total_positive() public {
        treasury.setTotalAllowance(address(0x3), 1E18);
        treasury.setPerBlockAllowance(address(0x3), uint(-1));
        treasuryReseter.resetTotalAllowance(address(0x3));

        (uint totalAllowance, uint perBlockAllowance) = treasury.getAllowance(address(0x3));
        assertEq(totalAllowance, uint(-1));
        assertEq(perBlockAllowance, uint(-1));
    }
    function test_reset_when_per_block_normal_total_positive() public {
        treasury.setTotalAllowance(address(0x3), 1E18);
        treasury.setPerBlockAllowance(address(0x3), 1E18);
        treasuryReseter.resetTotalAllowance(address(0x3));

        (uint totalAllowance, uint perBlockAllowance) = treasury.getAllowance(address(0x3));
        assertEq(totalAllowance, uint(-1));
        assertEq(perBlockAllowance, 1E18);
    }
}

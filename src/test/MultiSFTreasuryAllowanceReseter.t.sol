pragma solidity 0.6.7;

import "ds-test/test.sol";
import "geb/multi/MultiStabilityFeeTreasury.sol";
import "geb/multi/MultiSAFEEngine.sol";
import "geb/shared/Coin.sol";
import {MultiCoinJoin} from "geb/shared/BasicTokenAdapters.sol";

import "../MultiSFTreasuryAllowanceReseter.sol";

abstract contract Hevm {
    function warp(uint256) virtual public;
}
contract MultiSFTreasuryAllowanceReseterTest is DSTest {
    Hevm hevm;

    MultiSFTreasuryAllowanceReseter treasuryReseter;
    MultiSAFEEngine safeEngine;
    Coin coin;
    MultiCoinJoin coinJoin;
    MultiStabilityFeeTreasury treasury;

    bytes32 coinName = "BAI";

    uint constant HUNDRED = 10 ** 2;

    function setUp() public {
        hevm = Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        hevm.warp(604411200);

        safeEngine      = new MultiSAFEEngine();
        coin            = new Coin("RAI", "RAI", 99);
        coinJoin        = new MultiCoinJoin(coinName, address(safeEngine), address(coin));
        treasury        = new MultiStabilityFeeTreasury(address(safeEngine));
        treasuryReseter = new MultiSFTreasuryAllowanceReseter(coinName, address(treasury));

        safeEngine.initializeCoin(coinName, uint(-1));
        treasury.initializeCoin(
          coinName,
          address(coinJoin),
          address(0x123),
          HUNDRED,
          uint(-1),
          1,
          1,
          1
        );

        treasury.addAuthorization(coinName, address(treasuryReseter));
    }

    function test_setup() public {
        assertEq(address(treasuryReseter.treasury()), address(treasury));
    }
    function testFail_reset_when_per_block_null_total_null() public {
        treasuryReseter.resetTotalAllowance(address(0x3));
    }
    function test_reset_when_per_block_tiny_total_null() public {
        treasury.setPerBlockAllowance(coinName, address(0x3), 1);
        treasuryReseter.resetTotalAllowance(address(0x3));

        (uint totalAllowance, uint perBlockAllowance) = treasury.getAllowance(coinName, address(0x3));
        assertEq(totalAllowance, uint(-1));
        assertEq(perBlockAllowance, 1);
    }
    function test_reset_when_per_block_max_total_null() public {
        treasury.setPerBlockAllowance(coinName, address(0x3), uint(-1));
        treasuryReseter.resetTotalAllowance(address(0x3));

        (uint totalAllowance, uint perBlockAllowance) = treasury.getAllowance(coinName, address(0x3));
        assertEq(totalAllowance, uint(-1));
        assertEq(perBlockAllowance, uint(-1));
    }
    function test_reset_when_per_block_normal_total_null() public {
        treasury.setPerBlockAllowance(coinName, address(0x3), 1E18);
        treasuryReseter.resetTotalAllowance(address(0x3));

        (uint totalAllowance, uint perBlockAllowance) = treasury.getAllowance(coinName, address(0x3));
        assertEq(totalAllowance, uint(-1));
        assertEq(perBlockAllowance, 1E18);
    }
    function testFail_reset_when_per_block_null_total_positive() public {
        treasury.setTotalAllowance(coinName, address(0x3), 1E18);
        treasuryReseter.resetTotalAllowance(address(0x3));
    }
    function test_reset_when_per_block_tiny_total_positive() public {
        treasury.setTotalAllowance(coinName, address(0x3), 1E18);
        treasury.setPerBlockAllowance(coinName, address(0x3), 1);
        treasuryReseter.resetTotalAllowance(address(0x3));

        (uint totalAllowance, uint perBlockAllowance) = treasury.getAllowance(coinName, address(0x3));
        assertEq(totalAllowance, uint(-1));
        assertEq(perBlockAllowance, 1);
    }
    function test_reset_when_per_block_max_total_positive() public {
        treasury.setTotalAllowance(coinName, address(0x3), 1E18);
        treasury.setPerBlockAllowance(coinName, address(0x3), uint(-1));
        treasuryReseter.resetTotalAllowance(address(0x3));

        (uint totalAllowance, uint perBlockAllowance) = treasury.getAllowance(coinName, address(0x3));
        assertEq(totalAllowance, uint(-1));
        assertEq(perBlockAllowance, uint(-1));
    }
    function test_reset_when_per_block_normal_total_positive() public {
        treasury.setTotalAllowance(coinName, address(0x3), 1E18);
        treasury.setPerBlockAllowance(coinName, address(0x3), 1E18);
        treasuryReseter.resetTotalAllowance(address(0x3));

        (uint totalAllowance, uint perBlockAllowance) = treasury.getAllowance(coinName, address(0x3));
        assertEq(totalAllowance, uint(-1));
        assertEq(perBlockAllowance, 1E18);
    }
}

pragma solidity 0.6.7;

abstract contract StabilityFeeTreasuryLike {
    function getAllowance(bytes32, address) virtual public view returns (uint256, uint256);
    function setTotalAllowance(bytes32, address, uint256) virtual external;
}
contract MultiSFTreasuryAllowanceReseter {
    // --- Variables ---
    bytes32                  public coinName;

    StabilityFeeTreasuryLike public treasury;

    // --- Events ---
    event ResetTotalAllowance(address account);

    constructor(bytes32 coinName_, address treasury_) public {
        require(treasury_ != address(0), "MultiSFTreasuryAllowanceReseter/null-treasury");

        coinName = coinName_;
        treasury = StabilityFeeTreasuryLike(treasury_);
    }

    /*
    * @notify Reset the total allowance for an address that has a positive perBlock allowance
    */
    function resetTotalAllowance(address account) external {
        (, uint perBlockAllowance) = treasury.getAllowance(coinName, account);
        require(perBlockAllowance > 0, "MultiSFTreasuryAllowanceReseter/null-per-block-allowance");
        treasury.setTotalAllowance(coinName, account, uint(-1));
        emit ResetTotalAllowance(account);
    }
}

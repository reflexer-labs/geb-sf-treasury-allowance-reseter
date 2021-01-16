pragma solidity ^0.6.7;

abstract contract StabilityFeeTreasuryLike {
    function getAllowance(address) public view returns (uint256, uint256);
    function setTotalAllowance(address, uint256) external;
}
contract SFTreasuryAllowanceReseter {
    StabilityFeeTreasuryLike public treasury;

    constructor(address treasury_) public {
        require(treasury_ != address(0), "SFTreasuryAllowanceReseter/null-treasury");
        treasury = StabilityFeeTreasuryLike(treasury_);
    }

    function resetTotalAllowance(address account) external {
        (, uint perBlockAllowance) = treasury.getAllowance();
        if (perBlockAllowance > 0) {
          treasury.setTotalAllowance(account, uint(-1));
        }
        emit ResetTotalAllowance(account);
    }
}

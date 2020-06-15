pragma solidity 0.5.8;


/// @title Holding
contract Holding {
    mapping (address => Holder) public holders;
    uint256 public initialLockedUpAmount = 0;
    uint256 public constant TARGET_AMOUNT = <@dev_replace_with_contract_Terms>;

    struct Holder {
        uint256 availableAmount;
        uint256 lockedUntilBlocktimestamp;
    }

    event FundsReleased(address indexed _releasedToAccount, uint256 _amount);

    /// @notice loads holding data and checks for sanity
    constructor()
        public
        payable
    {
        require(address(this).balance == TARGET_AMOUNT, "Balance should equal target amount.");
                                                                   
        initHoldingData();

        require(initialLockedUpAmount == TARGET_AMOUNT, "Target amount should equal actual amount");
    }

    /// @notice Rlease funds for a specific address
    /// @param holderAddress the ethereum address which should get its funds
    function releaseFunds(address payable holderAddress) 
        public 
    {
        Holder storage holder = holders[holderAddress];
        
        require(holder.availableAmount > 0, "Available amount is 0");
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp > holder.lockedUntilBlocktimestamp, "Holding period is not over");
        
        uint256 amountToTransfer = holder.availableAmount;
        holder.availableAmount = 0;
        holderAddress.transfer(amountToTransfer);
        emit FundsReleased(holderAddress, amountToTransfer);
    }

    // solhint-disable function-max-lines
    /// @notice loads holding data
    function initHoldingData()
        internal
    {
        addHolding(0x000ADD14422442, 0, 12345);
    } 
    // solhint-enable function-max-lines

    /// @notice Adds a holding entry
    /// @param holder owner of the holded funds
    /// @param amountToHold the amount that should be holded
    /// @param lockUntil the timestamp of the date until the funds should be locked up
    function addHolding(address holder, uint256 amountToHold, uint256 lockUntil) 
        internal
    {
        Holder storage selectedHolder = holders[address(holder)];

        require(
            selectedHolder.availableAmount == 0 && selectedHolder.lockedUntilBlocktimestamp == 0,
            "Holding for this address was already set."
        );

        initialLockedUpAmount += amountToHold;
        
        selectedHolder.availableAmount = amountToHold;
        selectedHolder.lockedUntilBlocktimestamp = lockUntil;
    }
}

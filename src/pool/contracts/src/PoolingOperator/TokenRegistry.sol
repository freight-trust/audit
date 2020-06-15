pragma solidity 0.5.4;
import "../kernel/Owned.sol";

/**
 * @title XTokenRegistry
 * @dev mapping between underlying assets and their corresponding XToken.
 * @dev This has not been audited please do not use in production
 */
contract TokenRegistry is Owned {

    address[] tokens;

    mapping (address => XTokenInfo) internal XToken;

    struct XTokenInfo {
        bool exists;
        uint128 index;
        address market;
    }

    event XTokenAdded(address indexed _underlying, address indexed _XToken);
    event XTokenRemoved(address indexed _underlying);

    /**
     * @dev Adds a new XToken to the registry.
     * @param _underlying The underlying asset.
     * @param _XToken The XToken.
     */
    function addXToken(address _underlying, address _XToken) external onlyOwner {
        require(!XToken[_underlying].exists, "CR: XToken already added");
        XToken[_underlying].exists = true;
        XToken[_underlying].index = uint128(tokens.push(_underlying) - 1);
        XToken[_underlying].market = _XToken;
        emit XTokenAdded(_underlying, _XToken);
    }

    /**
     * @dev Removes a XToken from the registry.
     * @param _underlying The underlying asset.
     */
    function removeXToken(address _underlying) external onlyOwner {
        require(XToken[_underlying].exists, "CR: XToken does not exist");
        address last = tokens[tokens.length - 1];
        if (_underlying != last) {
            uint128 targetIndex = XToken[_underlying].index;
            tokens[targetIndex] = last;
            XToken[last].index = targetIndex;
        }
        tokens.length --;
        delete XToken[_underlying];
        emit XTokenRemoved(_underlying);
    }

    /**
     * @dev Gets the XToken for a given underlying asset.
     * @param _underlying The underlying asset.
     */
    function getXToken(address _underlying) external view returns (address) {
        return XToken[_underlying].market;
    }

    /**
    * @dev Gets the list of supported underlyings.
    */
    function listUnderlyings() external view returns (address[] memory) {
        address[] memory underlyings = new address[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            underlyings[i] = tokens[i];
        }
        return underlyings;
    }
}
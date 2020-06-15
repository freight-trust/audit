pragma solidity ^0.4.18;

/// @title The ONSAccessControl that manages access privileges to transaction.
/// @author dalu
contract ONSAccessControl {

  /*
    manager : has a role that registers a user on the whitelist that is a list of user's addresses who can trade.
  */

  address public managerAddress;
  //owner allow user to add ons records for gs1 code.
  mapping(address => uint256) public owners;
  address[] ownerList;

  function ONSAccessControl() public {
    // constructor
    managerAddress = msg.sender;

    //owners mapping array's value should start from index 1;
    ownerList.push(address(0));
  }

  modifier onlyManager() {
    require(msg.sender == managerAddress);
    _;
  }

  function setManager(address _newManager) public onlyManager {
    require(_newManager != address(0));
    managerAddress = _newManager;
  }

  function getManager() public view returns(address) {
    return managerAddress;
  }

  function addOwner(address ownerAddress) public onlyManager returns(bool) {
    if (owners[ownerAddress] > 0)
      return false;

    owners[ownerAddress] = ownerList.push(ownerAddress)-1;
    return true;
  }

  function removeOwner(address ownerAddress) public onlyManager{
    require(owners[ownerAddress] > 0);
    delete ownerList[owners[ownerAddress]];
    delete owners[ownerAddress];
  }

  modifier onlyExistOwner(address ownerAddress) {
    require(owners[ownerAddress] > 0);
    _;
  }

  function isExistOwner(address ownerAddress) public view returns(bool) {
    if (owners[ownerAddress] > 0)
      return true;
    return false;
  }
}

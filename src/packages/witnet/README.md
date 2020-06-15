# witnet-ethereum-bridge [![](https://travis-ci.com/witnet/witnet-ethereum-bridge.svg?branch=master)](https://travis-ci.com/witnet/witnet-ethereum-brdige)

`witnet-ethereum-bridge` is an open source implementation of a bridge
from Ethereum to Witnet. This repository provides several contracts:

- The `WitnetRequestsBoard` (WRB), which includes all the needed functionality to relay data requests and their results from Ethereum to Witnet and the other way round.
- `WitnetRequestsBoardProxy`, that routes Witnet data requests from smart contracts to the appropriate `WitnetRequestsBoard` controller.
- `UsingWitnet`, an inheritable client contract that injects methods for interacting with the WRB in the most convenient way.

## WitnetRequestsBoardProxy

`WitnetRequestsBoardProxy.sol` is a proxy contract that routes Witnet data requests coming from the `UsingWitnet` contract to the appropriate `WitnetRequestBoard` controller. `WitnetRequestBoard` controllers are indexed by the last data request indentifier that each controller had stored before the controller was upgraded. Thus, if controller _a_ was replaced by controller _b_ at id _i_, petitions from _0_ to _i_ will be routed to _a_, while controller _b_ will handle petitions from _i_ onwards.

## WitnetRequestsBoard

The `WitnetRequestsBoard` contract provides the following methods:

- **postDataRequest**:
  - _description_: posts a data request into the WRB in expectation that it will be relayed and resolved 
  in Witnet with a total reward that equals to msg.value.
  - _inputs_:
    - *_dr*: the bytes corresponding to the Protocol Buffers serialization of the data request output.
    - *_tallyReward*: the amount of value that will be detracted from the transaction value and reserved for rewarding the reporting of the final result (aka __tally__) of the data request.
  - output:
    - *_id*: the unique identifier of the data request.

- **upgradeDataRequest**:
  - *description*: increments the rewards of a data request by 
  adding more value to it. The new request reward will be increased by `msg.value` minus the difference between the former tally reward and the new tally reward.
  - *_inputs*:
    - *_id*: the unique identifier of the data request.
    - *_tallyReward*: the new tally reward. Needs to be equal or greater than the former tally reward.

- **claimDataRequests**:
  - _description_: claims eligibility for relaying the data requests specified by the listed IDs
   and puts aside the potential data request inclusion reward for the 
   identity (public key hash) making the claim.
  - _inputs_:
    - *_ids*: the list of data request identifiers to be claimed.
    - *_poe*: a valid proof of eligibility generated by the bridge node that is claiming the
    data requests.

- **reportDataRequestInclusion**:
  - _description_: presents a proof of inclusion, proof of eligibility and a valid signature of the msg.sender to prove that the request was posted into Witnet so as to unlock the 
  inclusion reward that was put aside for the claiming identity (public key hash). The reward is only unlocked if the all proof verifications (inclusion, eligibility and signature) succeed.
  - _inputs_:
    - *_id*: the unique identifier of the data request.
    - *_poi*: a proof of inclusion proving that the data request appears listed in one recent block 
    in Witnet.
    - *_index*: index in the merkle tree.
    - *_blockHash*: the hash of the block in which the data request 
    was inserted.

- **reportResult**:
  - _description_: reports the result of a data request in Witnet.
  - _inputs_:
    - *_id*: the unique identifier of the data request.
    - *_poi*: a proof of inclusion proving that the data in `_result` has been acknowledged by the Witnet network as being the final result for the data request by putting in a tally transaction inside a Witnet block.
    - *_index*: the position of the tally transaction in the tallies-only merkle tree in the Witnet block.
    - *_blockHash*: the hash of the block in which the result (tally) 
    was inserted.
    - *_result*: the result itself as `bytes`.

- **checkDataRequestsClaimability**:
  - _description_: checks if data requests specified by the listed IDs are claimable or not.
  - _inputs_:
    - *_ids*: the list of data request identifiers to be claimed.
  - _output_:
    - an array of booleans indicating if data requests are claimable or not.

- **readDataRequest**:
  - _description_: retrieves the bytes of the serialization of one data request from the WRB.
  - _inputs_:
    - *_id*: the unique identifier of the data request.
  - _output_:
    - the data request bytes.

- **readResult**:
  - _description_: retrieves the result (if already available) of one data request from the WRB.
  - _inputs_:
    - *_id*: the unique identifier of the data request.
  - _output_:
    - the result of the data request as `bytes`.

- **readDrHash**:
  - _description_: retrieves the data request transaction hash in Witnet (if it has already been included and presented) of one data request from the WRB.
  - _inputs_:
    - *_id*: the unique identifier of the data request.
  - _output_:
    - the data request transaction hash.

- **getLastBeacon**:
  - _description_: queries the block relay contract to get knowledge of the last beacon inserted.
  - _output_:
    - the last beacon as byte concatenation of (block_hash||epoch).

- **requestsCount**:
  - _description_: returns the number of data requests in the WRB.
  - _output_:
    - the number of data requests in the WRB.

In addition, `WitnetRequestsBoard` inherits the `VRF` contract from https://github.com/witnet/vrf-solidity, and as such, all its public methods are also available to be queried. This is extremely important as the proof of eligibility is verified with the `fastVerify` method, which requires some auxiliary data points in addition to the proof itself. These can be calculated using the following methods:

- *computeFastVerifyParams*: which computes the necessary auxiliary points to perform the fast (and cheaper) verification in the WRB.
- *decodeProof*: if the proof is serialized and needs to be decomposed, this function decodes a VRF proof into the parameters [Gamma_x, Gamma_y c, s].
- *decodePoint*: if the point is in compressed format, this function decodes a compressed secp256k1 point into its uncompressed representation [P_x, P_y].

## UsingWitnet

The `UsingWitnet` contract injects the following methods into the contracts inheriting from it:

- **witnetPostRequest**:
  - _description_: call to the WRB's `postDataRequest` method to post a 
  data request into the WRB so its is resolved in Witnet with total reward 
  specified in `msg.value`.
  - _inputs_:
    - *_dr*: the bytes corresponding to the Protocol Buffers serialization of the data request output.
    - *_tallyReward*: the amount of value that will be detracted from the transaction value and reserved for rewarding the reporting of the final result (aka __tally__) of the data request.
     that is destinated to reward the result inclusion.
  - _output_:
    - *_id*: the unique identifier of the data request.

- **witnetUpgradeRequest**:
  - _description_: call to the WRB's `upgradeDataRequest` method to increment the total reward of the data request by adding more value to it. The new request reward will be increased by `msg.value` minus the difference between the former tally reward and the new tally reward.
  - _inputs_:
    - *_id*: the unique identifier of the data request.
    - *_tallyReward*: the new tally reward. Needs to be equal or greater than the former tally reward.

- **witnetReadResult**:
  - _description_: call to the WRB's `readResult` method to retrieve
   the result of one data request from the WRB.
  - _inputs_:
    - *_id*: the unique identifier of the data request.
  - _output_:
    - the result of the data request as `bytes`.

- **witnetCheckRequestAccepted**:
  - _description_: check if a request has been accepted into Witnet.
  Contracts depending on Witnet should not start their main business logic (e.g. receiving value from third parties) before this method returns `true`.
  - _inputs_:
    - *_id*: the unique identifier of the data request.
  - _output_:
    - boolean telling if the request has been already accepted or not.

## Usage

The `UsingWitnet.sol` contract can be used directly by inheritance:

```solidity
pragma solidity >=0.5.3 <0.7.0;;

import "./UsingWitnet.sol";

contract Example is UsingWitnet {

  uint256 drCost = 10;
  uint256 tallyReward = 5;
  bytes memory dr = /* Here goes the data request serialized bytes. */;

  function myOwnDrPost() public returns(uint256 id) {
    id =  witnetPostDataRequest.value(drCost)(dr, tallyReward);
  }
}
```

## License

`witnet-ethereum-bridge` is published under the [MIT license][license].

[license]: https://github.com/witnet/witnet-ethereum-bridge/blob/master/LICENSE
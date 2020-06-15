pragma solidity ^ 0.5.10;


contract DynamicBinding {
    bytes32 hashKey;
    bool init;
    address owner;
    function initial(bytes32 key) {
        if (init != true) {
            hashKey = key;
            init = true;
            owner = msg.sender;
        }
    }
    function changeKey(string oldKey, bytes32 newKey) {
        if (init == true) 
            if (hashKey == sha256(oldKey)) 
                if (owner == msg.sender) 
                    hashKey = newKey;
                
            
        


    }
    modifier verify(string inputKey) {
        if (hashKey == sha256(inputKey)) {;
        }
    }
}
contract ServiceAgreement is DynamicBinding {
    string firstParty;
    string secondParty;
    bytes32 contractHash;
    ...function queryAgreement(string key)
    verify(key)constant returns(string, string, bytes32) {
        return firstParty,
        secondParty,
        contractHash;
    }
    ...
}

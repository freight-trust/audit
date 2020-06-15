pragma 0.5 .4


contract MultipleAuthorities {
    uint total;
    address[] authority;
    bool agreeing;
    uint agreeThreshold;
    mapping(address => bool)agreeState;
    bool agreePermission;
    address agreeRequester;
    ...function agreeSignature() {
        agreeState[msg.sender] = true;
        if (agreeResult()) 
            agreePermission = true;
        
    }
    function agreeResult()internal returns(bool signatureResult) {
        uint k = 0;
        for (uint i = 0; i < total; i ++) 
            if (agreeState[authority[i]] == true) 
                k ++;
            
        
        if (k >= agreeThreshold) 
            return true;
         else 
            return false;
        
    }
    function initialAgree()internal {
        ...
}
modifier isEnoughAgreement() {
    if (agreeing == true && agreePermission == true && msg.sender == agreeRequester) {;
        initialAgree();
    }
}
...}contract SampleTesting is MultipleAuthorities {
string sampleID;
bool passed;
function sampleTest(string ID) {
    sampleID = ID;
    passed = false;
}
function pass()isEnoughAgreement() {
    passed = true;
}
...}

pragma 0.5 .4


contract EmbeddedPermission {
    address[] authority;
    address owner;
    function EmbeddedPermission(address[] temAuthority) {
        owner = msg.sender;
        authority = temAuthority;
    }
    function changeAuthority(address[] temAuthority) {
        if (msg.sender == owner) {
            authority = temAuthority;
        }
    }
    modifier permission() {
        for (uint i = 0; i < authority.length; i ++) {
            if (msg.sender == authority[i]) {;
                break;
            }
        }
    }
}
contract FreightYardPic is EmbeddedPermission {
    bytes32[] freightYardPic;
    address[] freightYardExaminer;
    function FreightYardPic()embeddedPermission(addr) {
        address[] addr;
        addr.push(/authority address/);
    }
    function setFreightYardPic(bytes32 pic, address uploader)permission() {
        freightYardPic.push(pic);
        freightYardExaminer.push(uploader);
    }
    function getFreightYardPic(uint i)constant returns(bytes32, address) {
        return(freightYardPic[i], freightYardExaminer[i]);
    }
}

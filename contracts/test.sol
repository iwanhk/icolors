pragma solidity ^0.8.4;

/*
                  ___           ___           ___       ___           ___           ___     
      ___        /\  \         /\  \         /\__\     /\  \         /\  \         /\  \    
     /\  \      /::\  \       /::\  \       /:/  /    /::\  \       /::\  \       /::\  \   
     \:\  \    /:/\:\  \     /:/\:\  \     /:/  /    /:/\:\  \     /:/\:\  \     /:/\ \  \  
     /::\__\  /:/  \:\  \   /:/  \:\  \   /:/  /    /:/  \:\  \   /::\~\:\  \   _\:\~\ \  \ 
  __/:/\/__/ /:/__/ \:\__\ /:/__/ \:\__\ /:/__/    /:/__/ \:\__\ /:/\:\ \:\__\ /\ \:\ \ \__\
 /\/:/  /    \:\  \  \/__/ \:\  \ /:/  / \:\  \    \:\  \ /:/  / \/_|::\/:/  / \:\ \:\ \/__/
 \::/__/      \:\  \        \:\  /:/  /   \:\  \    \:\  /:/  /     |:|::/  /   \:\ \:\__\  
  \:\__\       \:\  \        \:\/:/  /     \:\  \    \:\/:/  /      |:|\/__/     \:\/:/  /  
   \/__/        \:\__\        \::/  /       \:\__\    \::/  /       |:|  |        \::/  /   
                 \/__/         \/__/         \/__/     \/__/         \|__|         \/__/    
*/

import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721A.sol";

contract testMint is ERC721A {
    using Strings for uint256;

    constructor() ERC721A("iColors.NFT", "ICS") {}

    function test(uint256 amount) external {
        _safeMint(msg.sender, amount);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return tokenId.toString();
    }
}

contract testArry {
    using Strings for uint256;

    uint256[] public list;
    string public message = "";

    function tryme() public returns (string memory) {
        list.push(1);
        list.push(2);
        list.push(3);
        list.push(4);

        delete list[2];

        for (uint256 i; i < list.length; i++) {
            message = string(abi.encodePacked(message, list[i].toString()));
        }

        return message;
    }
}

contract testContract {
    uint256 public id;
    uint256 public r;
    uint256 public g;
    uint256 public b;

    uint256[] list;

    function set(uint256 _id) public {
        id = _id;
        r = id % 1000;
        g = (id / 1000) % 1000;
        b = (id / 1000 / 1000) % 1000;
    }

    function toString(address account) public pure returns (bytes memory) {
        return abi.encodePacked(account);
    }

    function toString(uint256 value) public pure returns (bytes memory) {
        return abi.encodePacked(value);
    }

    function toString(bytes32 value) public pure returns (bytes memory) {
        return abi.encodePacked(value);
    }

    function toString(bytes memory data) public pure returns (bytes memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return str;
    }

    function print() external view returns (bytes memory) {
        return toString(msg.sender);
    }

    function printBuffer(bytes memory data)
        external
        pure
        returns (bytes memory)
    {
        return toString(data);
    }
}

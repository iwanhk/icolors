// SPDX-License-Identifier: MIT
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
import "./Base64.sol";
import "./ERC721A.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IIsotop {
    function registerProject() external;

    function getCode(uint256 tokenId) external returns (string memory);

    function randCode(uint256 tokenId) external returns (string memory);

    function claim(
        uint256 tokenId,
        address _owner,
        string calldata _code
    ) external;
}

contract T20 is ERC20 {
    constructor() ERC20("T20", "T20") {
        _mint(msg.sender, 100 * 10**18);
    }
}

contract T721 is ERC721A {
    string[] public owners;
    IIsotop isp;

    constructor(address _isotop) ERC721A("TOY SWARD", "T721") {
        isp = IIsotop(_isotop);
        isp.registerProject();
    }

    function mint() external {
        owners.push(isp.randCode(owners.length));
        _safeMint(msg.sender, 1);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Nonexistent token");
        return owners[tokenId];
    }

    function secretCode(uint256 tokenId, string calldata code)
        external
        returns (string memory)
    {
        isp.claim(tokenId, msg.sender, code);

        return "Congratulations! you got a color, go iColors.xyz to check it";
    }
}

contract testHex {
    using Strings for uint256;

    uint256 public value;
    uint8 public r;
    uint8 public g;
    uint8 public b;
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toHLHexString(uint24 v) public pure returns (string memory) {
        bytes memory buffer = new bytes(6);
        for (uint256 i = 6; i > 0; i--) {
            buffer[i - 1] = _HEX_SYMBOLS[v & 0xf];
            v >>= 4;
        }
        require(v == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    function set(uint24 _value) public {
        r = uint8(_value >> 16);
        g = uint8((_value << 8) >> 16);
        b = uint8((_value << 16) >> 16);
    }

    function out(string memory name) public pure returns (string memory) {
        bytes memory _name = bytes(name);
        bytes memory uriBuffer;

        uint256 tokenId = 1;

        if (bytes(_name).length == 0) {
            // No name set
            _name = abi.encodePacked("iColors#", tokenId.toString(), "*");
        }

        if (_name[_name.length - 1] == "*") {
            // remove the last '*'
            assembly {
                mstore(_name, sub(mload(_name), 1))
            }
            for (uint256 i = 0; i < 5; i++) {
                _name = abi.encodePacked(_name, "\xe2\xad\x90\xef\xb8\x8f");
            }
        }
        uriBuffer = abi.encodePacked(
            '{"name": "',
            _name,
            '", "description": "iColors: I am just yet another color"',
            ', "image_data": "',
            "data:image/svg+xml;base64,",
            '", "designer": "LUCA355", "attributes": ['
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(string(abi.encodePacked(uriBuffer))))
                )
            );
    }

    function setShowName(string calldata _name)
        external
        pure
        returns (string memory)
    {
        bytes memory buffer = bytes(_name);
        if (buffer.length >= 6) {
            for (uint256 i = 0; i < buffer.length - 5; i++) {
                if (
                    buffer[i] == 0xe2 &&
                    buffer[i + 1] == 0xad &&
                    buffer[i + 2] == 0x90 &&
                    buffer[i + 3] == 0xef &&
                    buffer[i + 4] == 0xb8 &&
                    buffer[i + 5] == 0x8f
                ) {
                    buffer[i] = " ";
                    buffer[i + 1] = " ";
                    buffer[i + 2] = " ";
                    buffer[i + 3] = " ";
                    buffer[i + 4] = " ";
                    buffer[i + 5] = " ";
                }
            }
        }
        return string(buffer);
    }

    function size(string calldata _name) external pure returns (uint256) {
        return bytes(_name).length;
    }
}

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

    function at(address _addr) public view returns (bytes memory o_code) {
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(_addr)
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            o_code := mload(0x40)
            // new "memory end" including padding
            mstore(
                0x40,
                add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f)))
            )
            // store length in memory
            mstore(o_code, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(_addr, add(o_code, 0x20), 0, size)
        }
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

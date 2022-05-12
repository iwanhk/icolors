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

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @custom:security-contact iwan@isotop.top
import {Base64} from "./Base64.sol";
import {Random} from "./Random.sol";
import {SVG} from "./SVG.sol";

contract IColors is ERC1155, Ownable, Pausable {
    using Strings for uint256;
    using Strings for address;
    struct Attribute {
        address publisherAddr;
        string name;
        uint256 amount;
        uint256 index; // global index of color
    }
    struct Publisher {
        string name;
        string description;
        bool exists;
    }
    struct Reciever {
        uint256 globalId; // to find the color list
        uint256[] amount; // to find the color amount
        bool exists;
    }

    mapping(address => Publisher) private publishers;
    mapping(uint256 => Attribute) private attributes; // color -> Attr
    mapping(bytes32 => address) private hashIndex; // hex the colors and point to owner address
    uint256[][] private globalIds; // id to the colors list
    mapping(address => Reciever) private recievers;

    modifier tokenExists(uint256 tokenId) {
        require(tokenId < globalIds.length, "No token exists");
        address owner = ownerOf(tokenId);
        require(
            recievers[owner].exists || publishers[owner].exists,
            "No one own this token"
        );
        _;
    }

    constructor() ERC1155("icolors.xyz") {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function registerPublisher(
        string calldata name,
        string calldata description
    ) external {
        if (publishers[msg.sender].exists) {
            publishers[msg.sender].name = name;
            publishers[msg.sender].description = description;
        } else {
            publishers[msg.sender] = Publisher(name, description, true);
        }
    }

    function publish(
        string[] calldata _attributes,
        uint256[] calldata _colors,
        uint256[] calldata _amount
    ) external {
        require(
            _amount.length == _attributes.length &&
                _amount.length == _colors.length,
            "Arguments length not match"
        );

        uint256 totalItems = _attributes.length;

        uint256[] memory ids = new uint256[](totalItems);

        for (uint256 i = 0; i < totalItems; ++i) {
            //When publish, there will be only 1 color ID

            if (attributes[_colors[i]].publisherAddr != address(0)) {
                // Found a previours attribute
                attributes[_colors[i]].amount += _amount[i];
                ids[i] = attributes[_colors[i]].index;
            } else {
                bytes32 hash = keccak256(abi.encodePacked(_colors[i]));
                // To create an attribute
                attributes[_colors[i]] = Attribute(
                    msg.sender,
                    _attributes[i],
                    _amount[i],
                    globalIds.length
                );
                ids[i] = globalIds.length;
                globalIds.push([_colors[i]]); // Thth is a list with 1 element
                hashIndex[hash] = msg.sender;
            }
        }

        if (!publishers[msg.sender].exists) {
            publishers[msg.sender] = Publisher("Anonymous", "Anonymous", true);
        }

        _mintBatch(msg.sender, ids, _amount, "");
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (to == address(0) || from == address(0)) {
            return; // Do nothing to publisher or burn or mint
        }

        uint256 id;

        if (!recievers[to].exists) {
            id = globalIds.length;
            recievers[to] = Reciever(id, amounts, true);
            uint256[] memory blank = new uint256[](0);
            globalIds.push(blank);
        } else {
            _burn(to, recievers[to].globalId, 1);
            id = recievers[to].globalId;
        }

        uint256[] storage _colors = globalIds[id]; // the colors list reciever had

        // Merge the tokens
        // step1: burn all the NFT
        // step2: merge id and amount

        uint256 totalItems = ids.length;
        for (uint256 i = 0; i < totalItems; ++i) {
            // insert ids[i] to _colors list
            uint256 size = _colors.length;
            uint256 j = 0;

            for (; j < size; ++j) {
                // if color == item then insert it here, otherwise keep moving
                if (_colors[j] == ids[i]) {
                    recievers[to].amount[j] += amounts[i];
                    break;
                }
            }

            if (j == size) {
                _colors.push(ids[i]);
                recievers[to].amount.push(amounts[i]);
            }

            _burn(from, ids[i], amounts[i]);
        }
        globalIds.push(_colors);
        hashIndex[keccak256(abi.encodePacked(_colors))] = to;

        recievers[to].globalId = id;

        _mint(to, id, 1, "");
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        require(tokenId < globalIds.length, "No token exists");
        uint256[] memory _colors = globalIds[tokenId];
        bytes32 hash = keccak256(abi.encodePacked(_colors));
        return hashIndex[hash];
    }

    function totalSupply() external view returns (uint256) {
        uint256 count = 0;
        uint256 size = globalIds.length;

        for (uint256 i = 0; i < size; i++) {
            address owner = ownerOf(i);

            if (recievers[owner].exists || publishers[owner].exists) {
                count++;
            }
        }
        return count;
    }

    function totalPublished() external view returns (uint256) {
        uint256 count = 0;
        uint256 size = globalIds.length;

        for (uint256 i = 0; i < size; i++) {
            address owner = ownerOf(i);

            if (publishers[owner].exists) {
                count++;
            }
        }
        return count;
    }

    function dump(uint256 tokenId)
        external
        view
        tokenExists(tokenId)
        returns (string memory)
    {
        uint256[] memory _colors = globalIds[tokenId];
        address owner = ownerOf(tokenId);
        bytes memory info = abi.encodePacked(
            "TokenId: ",
            tokenId.toString(),
            " Owner : ",
            Strings.toHexString(uint256(uint160(owner)), 20)
        );
        uint256 length = _colors.length;

        if (publishers[owner].exists) {
            for (uint256 i = 0; i < length; ++i) {
                Attribute memory _attr = attributes[_colors[i]];

                info = abi.encodePacked(
                    info,
                    " Color [",
                    i.toString(),
                    "]:",
                    _colors[i].toString(),
                    " ",
                    _attr.name,
                    " Amount: ",
                    _attr.amount.toString()
                );
                if (publishers[_attr.publisherAddr].exists) {
                    info = abi.encodePacked(
                        info,
                        " Source: ",
                        publishers[_attr.publisherAddr].name,
                        " Description: ",
                        publishers[_attr.publisherAddr].description
                    );
                } else {
                    info = abi.encodePacked(
                        info,
                        " Source and Description Anonymous "
                    );
                }
            }
        }

        if (recievers[owner].exists) {
            Reciever memory reciever = recievers[owner];
            for (uint256 i = 0; i < length; ++i) {
                Attribute memory _attr = attributes[_colors[i]];

                info = abi.encodePacked(
                    info,
                    " Color [",
                    i.toString(),
                    "]:",
                    _colors[i].toString(),
                    " Amount: ",
                    reciever.amount[i].toString()
                );
                if (publishers[_attr.publisherAddr].exists) {
                    info = abi.encodePacked(
                        info,
                        " Source: ",
                        publishers[_attr.publisherAddr].name
                    );
                } else {
                    info = abi.encodePacked(info, " NA ");
                }
            }
        }

        return string(info);
    }

    function uri(uint256 tokenId)
        public
        view
        override
        tokenExists(tokenId)
        returns (string memory)
    {
        uint256[] memory _colorList = globalIds[tokenId];

        bytes memory uriBuffer;
        uint256 length = _colorList.length;

        for (uint256 i = 0; i < length; ++i) {
            Attribute memory _attr = attributes[_colorList[i]];
            Publisher memory _publisher = publishers[_attr.publisherAddr];

            bytes memory _img;
            bytes memory _attrStr;
            (_img, _attrStr) = handleAttrinutues(_attr, _colorList[i]);

            uriBuffer = abi.encodePacked(
                '{"name": "',
                _publisher.name,
                '", "description": "',
                _publisher.description,
                '", "image_data": "',
                "data:image/svg+xml;base64,",
                Base64.encode(_img),
                '", "artist": "',
                Strings.toHexString(uint256(uint160(_attr.publisherAddr)), 20),
                //abi.encodePacked(_attr.publisherAddr),
                _attrStr,
                "}"
            );
        }
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(string(abi.encodePacked(uriBuffer))))
                )
            );
    }

    function handleAttrinutues(Attribute memory _attr, uint256 _color)
        internal
        pure
        returns (bytes memory img, bytes memory attrStr)
    {
        bytes memory _img;
        bytes memory _attrStr;
        bytes memory colorString = abi.encodePacked(
            "rgb(",
            (_color % 1000).toString(),
            ",",
            ((_color / 1000) % 1000).toString(),
            ",",
            ((_color / 1000 / 1000) % 1000).toString(),
            ")"
        );
        _img = abi.encodePacked(
            SVG.head(),
            SVG.bg(colorString),
            SVG.textMiddle("rgb(205,133,63)", "20", _attr.name),
            SVG.tail()
        );

        _attrStr = abi.encodePacked(
            '" , "attributes": [{"trait_type": "',
            _attr.name,
            '","value": "',
            _attr.amount.toString(),
            '"}]'
        );
        return (_img, _attrStr);
    }
}

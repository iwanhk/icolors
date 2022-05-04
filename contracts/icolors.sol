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
        string color;
        uint256 amount;
        uint256 id;
    }
    struct Publisher {
        string name;
        string description;
        bool registered;
    }

    mapping (address=> Publisher) private publishers;
    mapping (bytes32=> Attribute) private attributes;
    bytes32[] private globalIds;

    modifier tokenExists(uint256 tokenId) {
        require(tokenId< globalIds.length, "No token exists");
        _;
    }
    constructor() ERC1155("icolors.xyz") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function registerPublisher(string calldata name, string calldata description) external {
            if(publishers[msg.sender].registered){
                publishers[msg.sender].name= name;
                publishers[msg.sender].description= description;
            }else{
                publishers[msg.sender]= Publisher(name, description, true);
            }
    }
    function publish(string[] calldata _attributes, string[] calldata _colors, uint256[] calldata _amount) external {
        require(_amount.length== _attributes.length && 
                _amount.length== _colors.length, "Arguments length not match");

        uint256 totalItems= _attributes.length;

        uint256[] memory ids= new uint256[](totalItems);

        for(uint256 i=0; i< totalItems; ++i){
            bytes32 hash= keccak256(abi.encodePacked(msg.sender, _attributes[i]));

            if(attributes[hash].publisherAddr!= address(0)){
                // Found a previours attribute
                // require(attributes[hash].color== _colors[i], "Color not match");
                attributes[hash].amount+= _amount[i];
                ids[i]= attributes[hash].id;

            }else{
                attributes[hash]= Attribute(msg.sender, _attributes[i], _colors[i], _amount[i], globalIds.length);
                ids[i]= globalIds.length;
                globalIds.push(hash);
            }
        }

        _mintBatch(msg.sender, ids, _amount, "");
    }

    function getIDPublished() public view returns(uint256){
        return globalIds.length;
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function dump(uint256 tokenId) public view tokenExists(tokenId) returns (string memory) {

        bytes32 hash= globalIds[tokenId];

        bytes memory info;

        info= abi.encodePacked("Attribute: ", 
                                attributes[hash].name,
                                " Amount: ",
                                attributes[hash].amount.toString());
        if(publishers[attributes[hash].publisherAddr].registered){
            info= abi.encodePacked(info, " Source: ", 
                                publishers[attributes[hash].publisherAddr].name,
                                " Description: ",
                                publishers[attributes[hash].publisherAddr].description);
        }else{
            info= abi.encodePacked(info, " Source and Description Anonymous");
        }
        return string(info);
    }


    function uri(uint256 tokenId) public override view tokenExists(tokenId) returns (string memory){
           bytes32 hash= globalIds[tokenId];
           Attribute memory _attr= attributes[hash];
           Publisher memory _publisher= publishers[_attr.publisherAddr];

           string memory name= _publisher.registered? _publisher.name: "Anonymous";
           string memory description= _publisher.registered? _publisher.description: "Anonymous";
           
           bytes memory uriBuffer;
           bytes memory _img;
           bytes memory _attrStr;
           (_img, _attrStr)= handleAttrinutues(_attr);

           uriBuffer= abi.encodePacked(
                '{"name": "', name,
                '", "description": "', description,
                '", "image_data": "',
                'data:image/svg+xml;base64,',
                Base64.encode(_img),
                '", "artist": "',
                Strings.toHexString(uint256(uint160(_attr.publisherAddr)), 20),
                //abi.encodePacked(_attr.publisherAddr),
                _attrStr,
                '}');

            return string(abi.encodePacked(
                'data:application/json;base64,', Base64.encode(bytes(string(abi.encodePacked(uriBuffer))))));
    }

    function handleAttrinutues(Attribute memory _attr) internal pure returns (bytes memory img, bytes memory attrStr) {
        bytes memory _img;
        bytes memory _attrStr;

        _img= abi.encodePacked(SVG.head(),
                             SVG.bg(_attr.color),
                             SVG.textMiddle("rgb(205,133,63)", "20", _attr.name),
                             SVG.tail());

        _attrStr= abi.encodePacked('" , "attributes": [{"trait_type": "',
                            _attr.name,
                            '","value": "',
                            _attr.amount.toString(),
                            '"}]');
        return (_img, _attrStr);
    }
}

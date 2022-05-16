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
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract iColors is Ownable {
    using Strings for uint256;

    event Published(address from, uint256 count, uint256 fee);
    event Minted(
        address from,
        address to,
        string color,
        uint24 amount,
        uint256 fee
    );

    struct Publisher {
        uint24[] colorList;
        string name;
        string description;
        bool exists;
    }

    struct Holder {
        uint24[] colorList;
        uint24[] amounts;
        bool exists;
    }

    struct Color {
        string attr;
        uint24 amount;
        address publisher;
    }

    mapping(address => Publisher) publishers;
    mapping(address => Holder) holders;
    mapping(uint256 => Color) colors;
    address[] globalTokens;

    uint256 public Rate = 1;
    uint256 public Floor = 0.0001 ether;

    constructor() {}

    function holder(uint256 tokenId) external view returns (address) {
        return globalTokens[tokenId];
    }

    function isHolder(address who) external view returns (bool) {
        return holders[who].exists;
    }

    function publish(
        string calldata _name,
        string calldata _description,
        uint24[] calldata _colors,
        uint24[] calldata _amounts,
        string[] calldata _attrs
    ) external payable {
        uint256 weight = 0;

        if (publishers[msg.sender].exists) {
            if (bytes(_name).length > 0) {
                // Only change name when not empty
                publishers[msg.sender].name = _name;
                publishers[msg.sender].description = _description;
                weight = bytes(_name).length + bytes(_description).length;
            }
            // search very color to merge them
            uint256 size = publishers[msg.sender].colorList.length;

            for (uint256 i = 0; i < _colors.length; i++) {
                require(
                    colors[_colors[i]].publisher == address(0) ||
                        colors[_colors[i]].publisher == msg.sender,
                    "Color userd"
                );

                uint256 j;
                for (j = 0; j < size; j++) {
                    if (publishers[msg.sender].colorList[j] == _colors[i]) {
                        colors[_colors[i]].amount += _amounts[i];
                        break;
                    }
                }
                if (j == size) {
                    // this is a new color
                    publishers[msg.sender].colorList.push(_colors[i]);
                    colors[_colors[i]] = Color(
                        _attrs[i],
                        _amounts[i],
                        msg.sender
                    );
                }
                weight += bytes(_attrs[i]).length * _amounts[i];
            }
        } else {
            // New publisher, first time publish

            publishers[msg.sender] = Publisher(
                _colors,
                _name,
                _description,
                true
            );
            weight = Floor + bytes(_name).length + bytes(_description).length;

            for (uint256 i = 0; i < _colors.length; i++) {
                require(
                    colors[_colors[i]].publisher == address(0) ||
                        colors[_colors[i]].publisher == msg.sender,
                    "Color userd"
                );
                colors[_colors[i]] = Color(_attrs[i], _amounts[i], msg.sender);
                weight += bytes(_attrs[i]).length * _amounts[i];
            }
        }

        require(msg.value >= weight * Rate, "No enought funds");
        payable(msg.sender).transfer(msg.value - weight * Rate);
        emit Published(msg.sender, _colors.length, weight);
    }

    function mint(
        address _who,
        address _to,
        uint24 _color,
        uint24 _amount
    ) external payable returns (uint256, bool) {
        require(colors[_color].publisher == _who, "Not owner");
        require(colors[_color].amount >= _amount, "No enough color items");
        bool doMint = false;

        if (!holders[_to].exists) {
            // This is first time mint to a holder
            uint24[] memory blank = new uint24[](0);

            holders[_to] = Holder(blank, blank, true);
            holders[_to].colorList.push(_color);
            holders[_to].amounts.push(_amount);
            globalTokens.push(_to);

            doMint = true;
        } else {
            // add the color to previour list
            uint256 size = holders[_to].colorList.length;
            uint256 i;
            for (i = 0; i < size; i++) {
                if (holders[_to].colorList[i] == _color) {
                    holders[_to].amounts[i] += _amount;
                    break;
                }
            }

            if (i == size) {
                // merge colors
                holders[_to].colorList.push(_color);
                holders[_to].amounts.push(_amount);
            }
        }

        colors[_color].amount -= _amount;

        uint256 weight = bytes(colors[_color].attr).length * _amount;

        emit Minted(_who, _to, colors[_color].attr, _amount, weight);

        return (weight, doMint);
    }

    function _beforeTokenTransfers(
        address _from,
        address _to,
        uint256 _tokenId
    ) external onlyOwner returns (bool) {
        Holder memory _From = holders[_from];

        if (!holders[_to].exists) {
            // This is first time mint to a holder

            holders[_to] = _From;
            globalTokens[_tokenId] = _to;
            delete holders[_from];
            return false;
        } else {
            // add the color to previour list
            uint256 j;
            uint256 size = holders[_to].colorList.length;
            for (j = 0; j < _From.colorList.length; j++) {
                uint256 i;
                for (i = 0; i < size; i++) {
                    if (holders[_to].colorList[i] == _From.colorList[j]) {
                        holders[_to].amounts[i] += _From.amounts[j];
                        break;
                    }
                }
                if (i == size) {
                    // merge colors
                    holders[_to].colorList.push(_From.colorList[j]);
                    holders[_to].amounts.push(_From.amounts[j]);
                }
            }
            delete globalTokens[_tokenId];
            delete holders[_from];
            return true;
        }
    }

    function tokenURI(uint256 tokenId, string calldata tokenShowName)
        public
        view
        onlyOwner
        returns (string memory)
    {
        Holder memory _holder = holders[globalTokens[tokenId]];
        uint256 length = _holder.colorList.length;
        bytes memory uriBuffer;
        bytes memory _name = bytes(tokenShowName);
        if (_name.length == 0) {
            // No name set
            _name = abi.encodePacked("iColors#", tokenId.toString(), "*");
        }

        if (_name[_name.length - 1] == "*") {
            // remove the last '*'
            assembly {
                mstore(_name, sub(mload(_name), 1))
            }
            for (uint256 i = 0; i < length; i++) {
                // ⭐️ = "\xe2\xad\x90\xef\xb8\x8f"
                _name = abi.encodePacked(_name, "\xe2\xad\x90\xef\xb8\x8f");
            }
        }

        uriBuffer = abi.encodePacked(
            '{"name": "',
            _name,
            '", "description": "iColors: I am just yet another color"',
            ', "image_data": "',
            "data:image/svg+xml;base64,",
            Base64.encode(svgImage(tokenId)),
            '", "designer": "LUCA355", "attributes": ['
        );
        for (uint256 i = 0; i < length; ++i) {
            Color memory _color = colors[_holder.colorList[i]];
            uriBuffer = abi.encodePacked(
                uriBuffer,
                '{"trait_type": "',
                _color.attr,
                '", "value": "',
                uint256(_holder.amounts[i]).toString(),
                '"},'
            );
        }

        // remove the last ','
        assembly {
            mstore(uriBuffer, sub(mload(uriBuffer), 1))
        }

        uriBuffer = abi.encodePacked(uriBuffer, "]}");
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(string(abi.encodePacked(uriBuffer))))
                )
            );
    }

    function svgImage(uint256 tokenId) internal view returns (bytes memory) {
        Holder memory _holder = holders[globalTokens[tokenId]];
        uint256 count = _holder.colorList.length;
        uint256 weight = 0;
        bytes
            memory buffer = '<?xml version="1.0"?><svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg"> ';
        for (uint256 i = 0; i < count; i++) {
            weight += _holder.amounts[i];
        }
        uint256 _width = 500 / weight == 0 ? 1 : 500 / weight;
        uint256 _x = 0;

        for (uint256 i = 0; i < count; ++i) {
            uint24 _colorValue = _holder.colorList[i];
            uint24 _amount = _holder.amounts[i];

            uint8 r = uint8(_colorValue >> 16);
            uint8 g = uint8((_colorValue << 8) >> 16);
            uint8 b = uint8((_colorValue << 16) >> 16);

            buffer = abi.encodePacked(
                buffer,
                ' <rect x="',
                _x.toString(),
                '" y="0" width="',
                (_width * _amount).toString(),
                '" height="500" style="fill:rgb(',
                uint256(r).toString(),
                ",",
                uint256(g).toString(),
                ",",
                uint256(b).toString(),
                ')"/> '
            );
            _x += _width * _amount;
        }

        return abi.encodePacked(buffer, "</svg>");
    }

    function token(uint256 tokenId) external view returns (string memory info) {
        address owner = globalTokens[tokenId];
        require(holders[owner].exists, "No holder found");

        info = string(
            abi.encodePacked(
                "Token[",
                tokenId.toString(),
                '] \nOwner: "',
                Strings.toHexString(uint256(uint160(owner)), 20),
                '" \n'
            )
        );

        uint256 size = holders[owner].colorList.length;
        for (uint256 i = 0; i < size; i++) {
            Color memory _color = colors[holders[owner].colorList[i]];
            info = string(
                abi.encodePacked(
                    info,
                    _color.attr,
                    ": ",
                    uint256(holders[owner].amounts[i]).toString(),
                    "\n"
                )
            );
        }
    }

    function publisher(address _p) external view returns (string memory info) {
        if (!publishers[_p].exists) {
            return "No publisher found";
        }
        info = string(
            abi.encodePacked(
                "Publisher: ",
                publishers[_p].name,
                " \n",
                publishers[_p].description,
                "\n"
            )
        );
        uint256 size = publishers[_p].colorList.length;
        for (uint256 i = 0; i < size; i++) {
            Color memory _color = colors[publishers[_p].colorList[i]];
            info = string(
                abi.encodePacked(
                    info,
                    _color.attr,
                    ": ",
                    uint256(_color.amount).toString(),
                    "\n"
                )
            );
        }
    }

    function withdraw(address payable _who) external onlyOwner {
        _who.transfer(address(this).balance);
    }

    function setPrice(uint256 _Floor, uint256 _Rate) external onlyOwner {
        Rate = _Rate;
        Floor = _Floor;
    }
}

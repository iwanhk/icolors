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
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721A.sol";
import "./Base64.sol";

contract iColorsNFT is Ownable, ERC721A {
    using Strings for uint256;

    event Published(address from, uint256 count, uint256 fee);
    event Minted(
        address from,
        address to,
        string color,
        uint256 amount,
        uint256 fee
    );

    struct Publisher {
        uint256[] colorList;
        string name;
        string description;
        bool exists;
    }

    struct Holder {
        uint256[] colorList;
        uint256[] amounts;
        bool exists;
    }

    struct Color {
        string attr;
        uint256 amount;
        address publisher;
    }

    mapping(address => Publisher) public publishers;
    mapping(address => Holder) public holders;
    mapping(uint256 => Color) public colors;
    address[] public globalTokens;

    uint256 public Rate = 1;
    uint256 public Floor = 0.001 ether;

    modifier tokenExist(uint256 tokenId) {
        require(_exists(tokenId), "Nonexistent token");
        _;
    }

    modifier ownerOfToken(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "Only Owner");
        _;
    }

    constructor() ERC721A("iColors.NFT", "ICS") {}

    function publish(
        string calldata _name,
        string calldata _description,
        uint256[] calldata _colors,
        string[] calldata _attrs,
        uint256[] calldata _amounts
    ) external payable {
        uint256 weight = 0;

        if (publishers[msg.sender].exists) {
            if (bytes(_name).length > 0) {
                // Only change name when not empty
                publishers[msg.sender].name = _name;
                publishers[msg.sender].description = _description;
                weight += bytes(_name).length + bytes(_description).length;
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
            weight += Floor + bytes(_name).length + bytes(_description).length;

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
        require(msg.value >= weight * Rate, "Not enought funds");
        payable(msg.sender).transfer(msg.value - weight * Rate);

        emit Published(msg.sender, _colors.length, weight * Rate);
    }

    function mint(
        address _to,
        uint256 _color,
        uint256 _amount
    ) external payable {
        require(_amount > 0, "0 amount to mint");
        require(_to != address(0), "address 0 to mint");
        require(colors[_color].publisher == msg.sender, "Not owner");
        require(colors[_color].amount >= _amount, "No enough color items");

        if (!holders[_to].exists) {
            // This is first time mint to a holder
            uint256[] memory blank = new uint256[](0);

            holders[_to] = Holder(blank, blank, true);
            holders[_to].colorList.push(_color);
            holders[_to].amounts.push(_amount);
            globalTokens.push(_to);

            _safeMint(_to, 1);
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
        require(msg.value >= weight * Rate, "No enought funds");
        payable(msg.sender).transfer(msg.value - weight * Rate);

        emit Minted(
            msg.sender,
            _to,
            colors[_color].attr,
            _amount,
            weight * Rate
        );
    }

    function _beforeTokenTransfers(
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _amount
    ) internal virtual override {
        if (_from == address(0) || _to == address(0)) {
            // ignore mint or burn
            return;
        }

        require(_amount > 0, "0 amount to transfer");
        Holder memory _From = holders[_from];

        if (!holders[_to].exists) {
            // This is first time mint to a holder

            holders[_to] = _From;
            globalTokens[_tokenId] = _to;
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
            _burn(_tokenId);
        }
        delete holders[_from];
    }

    function setPrice(uint256 _Floor, uint256 _Rate) external onlyOwner {
        Rate = _Rate;
        Floor = _Floor;
    }

    function withDraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        tokenExist(tokenId)
        returns (string memory)
    {
        Holder memory _holder = holders[globalTokens[tokenId]];
        uint256 length = _holder.colorList.length;
        bytes memory uriBuffer;

        uriBuffer = abi.encodePacked(
            '{"name": "iColors[Traits:',
            length.toString(),
            ']", "description": "iColors: I am just yet another color"',
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
                _holder.amounts[i].toString(),
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

    function svgImage(uint256 tokenId) public view returns (bytes memory) {
        Holder memory _holder = holders[globalTokens[tokenId]];
        uint256 count = _holder.colorList.length;
        bytes
            memory buffer = '<?xml version="1.0"?><svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg"> ';

        uint256 _width = 500 / count;
        for (uint256 i = 0; i < count; ++i) {
            uint256 _colorValue = _holder.colorList[i];
            uint256 r = _colorValue % 1000;
            uint256 g = (_colorValue / 1000) % 1000;
            uint256 b = (_colorValue / 1000 / 1000) % 1000;

            buffer = abi.encodePacked(
                buffer,
                ' <rect x="',
                (_width * i).toString(),
                '" y="0" width="',
                _width.toString(),
                '" height="500" style="fill: rgb(',
                r.toString(),
                ",",
                g.toString(),
                ",",
                b.toString(),
                ')"/> '
            );
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
                    holders[owner].amounts[i].toString(),
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
                    _color.amount.toString(),
                    "\n"
                )
            );
        }
    }
}

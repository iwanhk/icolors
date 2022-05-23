// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

interface IDataTemplate {
    function get(uint256 id) external view returns (string memory);
}

library Metadata {
    using Strings for uint256;

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    bytes private constant _SVG_HEAD =
        '<?xml version="1.0"?><svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg"> ';
    bytes private constant _DESCRIPTION =
        '"description": "iColors: I am just yet another color"';
    bytes private constant _AUTHOR = '"designer": "LUCA355"';
    bytes private constant _NFT_NAME = "iColors#";

    function toHLHexString(uint24 value) internal pure returns (string memory) {
        bytes memory buffer = new bytes(6);
        for (uint256 i = 6; i > 0; i--) {
            buffer[i - 1] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    function uri(
        uint256 tokenId,
        bytes memory _name,
        uint256 _stars,
        bytes memory _svg,
        bytes memory _traits
    ) internal pure returns (string memory) {
        bytes memory uriBuffer;

        if (_name.length == 0) {
            // No name set
            _name = abi.encodePacked(_NFT_NAME, tokenId.toString(), "*");
        }

        if (_name[_name.length - 1] == "*") {
            // remove the last '*'
            assembly {
                mstore(_name, sub(mload(_name), 1))
            }
            for (uint256 i = 0; i < _stars; i++) {
                // ⭐️ = "\xe2\xad\x90\xef\xb8\x8f"
                _name = abi.encodePacked(_name, "\xe2\xad\x90\xef\xb8\x8f");
            }
        }

        uriBuffer = abi.encodePacked(
            '{"name": "',
            _name,
            '", ',
            _DESCRIPTION,
            ', "image_data": "data:image/svg+xml;base64,',
            Base64.encode(_svg),
            '", ',
            _AUTHOR,
            ', "attributes": [',
            _traits,
            "]}"
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(abi.encodePacked(uriBuffer))
                )
            );
    }

    function svgImage(
        uint24[] memory _colors,
        uint24[] memory _amounts,
        address dp
    ) internal view returns (bytes memory) {
        uint256 count = _colors.length;
        uint256 weight;
        bytes memory buffer = _SVG_HEAD;
        uint256 i;

        for (; i < count; ++i) {
            weight += _amounts[i];
        }
        uint256 _width = (500 * 100) / weight;
        uint256 _x;

        for (i = 0; i < count; ++i) {
            uint256 _realWidth = (_width * _amounts[i] + 51) / 100;
            _realWidth = _realWidth == 0 ? 1 : _realWidth;

            buffer = abi.encodePacked(
                buffer,
                ' <rect x="',
                _x.toString(),
                '" y="0" width="',
                _realWidth.toString(),
                '" height="500" style="fill:#',
                toHLHexString(_colors[i]),
                '"/> '
            );
            _x += _realWidth;
        }

        if (dp != address(0)) {
            buffer = abi.encodePacked(buffer, IDataTemplate(dp).get(0));
        }
        return abi.encodePacked(buffer, "</svg>");
    }
}

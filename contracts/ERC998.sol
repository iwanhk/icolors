// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./ERC721A.sol";

abstract contract ERC998 is ERC721A, IERC721Receiver {
    using Strings for uint256;
    struct assetItem {
        address contract0;
        uint256[] ids;
    }

    event Received(address _from, uint256 tokenId);

    mapping(uint256 => mapping(address => uint256[])) children721;
    address[] childrenContracts;

    function dockAsset(
        uint256 tokenId,
        address _contract,
        uint256 _id
    ) external {
        require(_contract != address(0), "Invalid arg");

        IERC721 erc721 = IERC721(_contract);
        if (children721[tokenId][_contract].length == 0) {
            // new record
            children721[tokenId][_contract] = new uint256[](0);
            childrenContracts.push(_contract);
        }
        // found a record
        children721[tokenId][_contract].push(_id);

        return erc721.transferFrom(msg.sender, address(this), _id);
    }

    function undockAsset(
        uint256 tokenId,
        address _contract,
        uint256 _id,
        address _to
    ) external {
        require(ownerOf(tokenId) == msg.sender, "Not Owner");
        //require(children721[tokenId][_contract].length != 0, "No Children");

        IERC721 erc721 = IERC721(_contract);

        uint256[] memory _ids = children721[tokenId][_contract];
        uint256 size = _ids.length;
        bool found = false;

        for (uint256 i = 0; i < size; i++) {
            if (_ids[i] == _id) {
                erc721.transferFrom(address(this), _to, _id);
                found = true;
            }
            if (found && i < size - 1) {
                children721[tokenId][_contract][i] = _ids[i + 1];
            }
        }

        if (found) {
            children721[tokenId][_contract].pop();
        } else {
            revert("Id not found");
        }
    }

    function tokenChildrenURI(uint256 tokenId)
        internal
        view
        returns (bytes memory)
    {
        bytes memory content = "";
        uint256 length = childrenContracts.length;

        for (uint256 i = 0; i < length; ++i) {
            address _contract = childrenContracts[i];

            if (children721[tokenId][_contract].length != 0) {
                // Fount ERC721 child
                IERC721Metadata erc721 = IERC721Metadata(_contract);

                content = abi.encodePacked(
                    content,
                    '{"trait_type": "ERC721 Assets.',
                    erc721.name(),
                    '", "value": "',
                    children721[tokenId][_contract].length.toString(),
                    '"},'
                );
            }
        }

        if (content.length > 0) {
            // remove the last ','
            assembly {
                mstore(content, sub(mload(content), 1))
            }
        }

        return content;
    }

    function transferAsset(uint256 tokenId, uint256 _newId) internal {
        uint256 size = childrenContracts.length;

        for (uint256 i = 0; i < size; i++) {
            address _contract = childrenContracts[i];
            uint256[] memory _ids = children721[tokenId][_contract];

            if (children721[_newId][_contract].length == 0) {
                children721[_newId][_contract] = new uint256[](0);
            }

            for (uint256 j = 0; j < _ids.length; j++) {
                children721[_newId][_contract].push(_ids[j]);
            }

            delete children721[tokenId][_contract];
        }
    }

    function assets(uint256 tokenId)
        internal
        view
        returns (assetItem[] memory assetList)
    {
        uint256 size = childrenContracts.length;
        assetItem[] memory _buffer = new assetItem[](size);
        uint256 _pointer = 0;

        for (uint256 i = 0; i < size; i++) {
            address _contract = childrenContracts[i];
            uint256[] memory _ids = children721[tokenId][_contract];

            if (children721[tokenId][_contract].length != 0) {
                _buffer[_pointer].ids = _ids;
                _buffer[_pointer].contract0 = _contract;
                _pointer++;
            }
        }

        assetList = new assetItem[](_pointer);
        while (_pointer > 0) {
            assetList[_pointer - 1] = _buffer[_pointer - 1];
            _pointer--;
        }
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external override returns (bytes4) {
        _operator;
        _from;
        _tokenId;
        _data;
        emit Received(_from, _tokenId);
        return 0x150b7a02;
    }
}

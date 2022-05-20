// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./ERC721A.sol";
import "./Base64.sol";

abstract contract ERC998 is ERC721A, IERC721Receiver {
    using Strings for uint256;

    event Received(address _from, uint256 tokenId);

    mapping(uint256 => mapping(address => uint256)) children20;
    mapping(uint256 => mapping(address => uint256[])) children721;
    address[] childrenContracts;

    function dockERC20(
        uint256 tokenId,
        address _contract,
        uint256 _amount
    ) external returns (bool) {
        require(_contract != address(0) && _amount > 0, "Invalid arg");

        IERC20 erc20 = IERC20(_contract);
        if (children20[tokenId][_contract] == 0) {
            // new record
            children20[tokenId][_contract] = _amount;
            childrenContracts.push(_contract);
        } else {
            // found a record
            children20[tokenId][_contract] += _amount;
        }

        return erc20.transferFrom(msg.sender, address(this), _amount);
    }

    function undockERC20(
        uint256 tokenId,
        address _contract,
        address _to,
        uint256 _amount
    ) external returns (bool) {
        require(
            _contract != address(0) && _to != address(0) && _amount > 0,
            "Invalid arg"
        );

        IERC20 erc20 = IERC20(_contract);
        if (children20[tokenId][_contract] < _amount) {
            revert("No enough tokens left");
        } else {
            children20[tokenId][_contract] -= _amount;
        }

        return erc20.transferFrom(address(this), _to, _amount);
    }

    function dockERC721(
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

    function undockERC721(
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
        bytes memory content;
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
            if (children20[tokenId][_contract] != 0) {
                // Fount ERC20  child
                IERC20Metadata erc20 = IERC20Metadata(_contract);

                content = abi.encodePacked(
                    content,
                    '{"trait_type": "ERC20 Assets.',
                    erc20.name(),
                    '", "value": "',
                    children20[tokenId][_contract].toString(),
                    '"},'
                );
            }
        }

        if (length > 0) {
            // remove the last ','
            assembly {
                mstore(content, sub(mload(content), 1))
            }
        }

        return content;
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

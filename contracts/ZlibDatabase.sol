// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./InflateLib.sol";

contract ZlibDatabase {
    struct DataType {
        bytes compressBytes;
        uint16 originSize;
        address owner;
    }

    mapping(string => DataType) public database;

    function store(
        string calldata _id,
        bytes calldata _data,
        uint16 _size
    ) external {
        DataType storage item = database[_id];

        require(
            item.owner == address(0) || item.owner == msg.sender,
            "Id used by others"
        );
        if (_data.length == 0 || _size == 0) {
            // clean the database item
            delete database[_id];
            return;
        }
        if (item.owner == address(0)) {
            database[_id] = DataType(_data, _size, msg.sender);
        } else {
            item.compressBytes = _data;
            item.originSize = _size;
        }
    }

    function get(string calldata _id) external view returns (string memory) {
        InflateLib.ErrorCode code;
        bytes memory buffer;

        (code, buffer) = InflateLib.puff(
            database[_id].compressBytes,
            database[_id].originSize
        );
        if (code == InflateLib.ErrorCode.ERR_NONE) {
            return string(buffer);
        }
        return string(database[_id].compressBytes);
    }
}

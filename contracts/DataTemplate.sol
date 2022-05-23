// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./InflateLib.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DataTemplate is Ownable {
    bytes[] private store;
    uint16[] private size;

    function upload(bytes calldata _data, uint16 _size)
        external
        onlyOwner
        returns (uint256)
    {
        require(_data.length > 0, "data is empty");
        store.push(_data);
        size.push(_size);
        return store.length - 1;
    }

    function update(
        uint256 id,
        bytes calldata _data,
        uint16 _size
    ) external onlyOwner {
        require(_data.length > 0, "data is empty");
        store[id] = _data;
        size[id] = _size;
    }

    function get(uint256 id) external view returns (string memory) {
        InflateLib.ErrorCode code;
        bytes memory buffer;
        (code, buffer) = InflateLib.puff(store[id], size[id]);
        if (code == InflateLib.ErrorCode.ERR_NONE) {
            return string(buffer);
        }
        return "";
    }

    function total() external view returns (uint256) {
        return store.length;
    }
}

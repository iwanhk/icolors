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

import "./ERC998.sol";
import "../interfaces/IColors.sol";

contract iColorsNFT is Ownable, ERC998 {
    mapping(address => string) showNames;
    IColors public ic;

    constructor(address _icolor) ERC721A("iColors.NFT", "ICO") {
        ic = IColors(_icolor);
    }

    function getIColors() external view returns (address) {
        return address(ic);
    }

    function setPrice(uint256 _Floor, uint256 _Rate) external onlyOwner {
        ic.setPrice(_Floor, _Rate);
    }

    function mint(
        address _to,
        uint24 _color,
        uint24 _amount
    ) external {
        require(_amount > 0, "0 amount to mint");
        require(_to != address(0), "address 0 to mint");

        if (ic.mint(msg.sender, _to, _color, _amount)) {
            _safeMint(_to, 1);
        }
    }

    function checkDockAssets() external view returns (assetItem[] memory) {
        if (!ic.isHolder(msg.sender)) {
            return new assetItem[](0);
        }
        return assets(ic.holder(msg.sender).globalId);
    }

    function checkDockAssets(uint256 tokenId)
        external
        view
        returns (assetItem[] memory)
    {
        if (!_exists(tokenId)) {
            return new assetItem[](0);
        }
        return assets(tokenId);
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

        require(_amount == 1, "only 1 NFT to transfer");
        uint256 _newId = ic._beforeTokenTransfers(_from, _to, _tokenId);
        if (_newId != _tokenId) {
            // the token had been merged
            transferAsset(_tokenId, _newId);
            _burn(_tokenId);
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Nonexistent token");
        return
            ic.tokenURI(
                tokenId,
                bytes(showNames[ic.holder(tokenId)]),
                tokenChildrenURI(tokenId)
            );
    }

    function setShowName(string calldata _name) external {
        require(ic.isHolder(msg.sender), "Not NFT owner");
        bytes memory buffer = bytes(_name);

        // remove the ⭐️ if user set it
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

        showNames[msg.sender] = string(buffer);
    }
}

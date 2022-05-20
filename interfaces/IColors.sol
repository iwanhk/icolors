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
interface IColors {
    struct Color {
        string attr;
        uint24 amount;
        address publisher;
    }
    struct Publisher {
        uint24[] colorList;
        string name;
        string description;
        bool exists;
    }
    struct Holder {
        uint24[] colorList;
        uint24[] amounts;
        uint256 globalId;
        bool exists;
    }

    function publisher(address _who) external view returns (Publisher memory);

    function color(uint24 _value) external view returns (Color memory);

    function isHolder(address _who) external view returns (bool);

    function holder(address _who) external view returns (Holder memory);

    function holder(uint256 tokenId) external view returns (address);

    function holder(uint24 colorsFilter)
        external
        view
        returns (address[] memory _holders);

    function mint(
        address _from,
        address _to,
        uint24 _color,
        uint24 _amount
    ) external returns (uint256 fee, bool doMint);

    function _beforeTokenTransfers(
        address _from,
        address _to,
        uint256 _tokenId
    ) external returns (bool doBurn);

    function tokenURI(
        uint256 tokenId,
        string calldata tokenShowName,
        bytes calldata childrenMeta
    ) external view returns (string memory);

    function svgImage(uint256 tokenId) external view returns (bytes memory);

    function token(uint256 tokenId) external view returns (string memory info);

    function withdraw(address payable _who) external;

    function setPrice(uint256 _Floor, uint256 _Rate) external;
}

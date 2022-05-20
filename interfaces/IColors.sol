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
    function holder(uint256 tokenId) external view returns (address);

    function isHolder(address who) external view returns (bool);

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

    function withdraw(address payable _who) external;

    function setPrice(uint256 _Floor, uint256 _Rate) external;
}

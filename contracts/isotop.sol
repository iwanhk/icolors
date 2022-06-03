// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Random.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface IColorsPuslisher {
    function publish(
        string calldata _name,
        string calldata _description,
        uint24[] calldata _colors,
        string[] calldata _attrs
    ) external;
}

interface IColorsNFT {
    function mint(
        address _to,
        uint24 _color,
        uint24 _amount
    ) external;

    function getIColors() external view returns (address);
}

contract isotop {
    address constant dead = 0x000000000000000000000000000000000000dEaD;
    address private owner;
    uint24[] colors;
    string[] codes;
    IColorsNFT iColorNFT;
    IColorsPuslisher iColor;

    mapping(address => bool) projectsExists;
    mapping(address => mapping(uint256 => uint256)) projects;
    mapping(address => mapping(uint256 => address)) owners;

    constructor(
        address _icolors,
        uint24[] memory _colors,
        string[] memory _codes
    ) payable {
        owner = msg.sender;
        iColorNFT = IColorsNFT(_icolors);
        iColor = IColorsPuslisher(iColorNFT.getIColors());

        for (uint256 i = 0; i < _codes.length; i++) {
            codes.push(_codes[i]);
            colors.push(_colors[i]);
        }

        publish(_colors, _codes);
    }

    function publish(uint24[] memory _colors, string[] memory _codes) public {
        require(owner == msg.sender, "only owner");

        iColor.publish(
            "isotop",
            "isotop is a public label system using chamecal",
            _colors,
            _codes
        );
    }

    function registerProject() external {
        projectsExists[msg.sender] = true;
    }

    function randCode(uint256 tokenId) external returns (string memory) {
        require(codes.length > 0, "No codes registered");
        require(projectsExists[msg.sender], "Project not registered");

        uint256 _id = Random.randrange(codes.length, tokenId);
        projects[msg.sender][tokenId] = _id;

        return codes[_id];
    }

    function getCode(uint256 tokenId) external returns (string memory) {
        require(codes.length > 0, "No codes registered");
        require(projectsExists[msg.sender], "Project not registered");

        uint256 _id = tokenId % codes.length;
        projects[msg.sender][tokenId] = _id;

        return codes[_id];
    }

    function claim(
        uint256 tokenId,
        address _owner,
        string calldata _code
    ) external {
        if (!projectsExists[msg.sender]) {
            // project contract not registered
            revert("Project not registered");
        }

        IERC721 _caller = IERC721(msg.sender);
        if (_caller.ownerOf(tokenId) != _owner) {
            // not owner of this token
            revert("Not token owner");
        }

        string memory code = codes[projects[msg.sender][tokenId]];
        if (keccak256(bytes(code)) != keccak256((bytes(_code)))) {
            revert("Wrong Secret-Code");
        }

        if (owners[msg.sender][tokenId] != address(0)) {
            // had been verified before
            revert("Address had been verified");
        }
        owners[msg.sender][tokenId] = dead;
        iColorNFT.mint(_owner, colors[projects[msg.sender][tokenId]], 1);
        // Note this verify can do once, if you transfer this NFT to others, the other can NOT have the opportinity
    }
}

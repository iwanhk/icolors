// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*                                      
   SSSSSSSSSSSSSSS VVVVVVVV           VVVVVVVV      GGGGGGGGGGGGG
 SS:::::::::::::::SV::::::V           V::::::V   GGG::::::::::::G
S:::::SSSSSS::::::SV::::::V           V::::::V GG:::::::::::::::G
S:::::S     SSSSSSSV::::::V           V::::::VG:::::GGGGGGGG::::G
S:::::S             V:::::V           V:::::VG:::::G       GGGGGG
S:::::S              V:::::V         V:::::VG:::::G              
 S::::SSSS            V:::::V       V:::::V G:::::G              
  SS::::::SSSSS        V:::::V     V:::::V  G:::::G    GGGGGGGGGG
    SSS::::::::SS       V:::::V   V:::::V   G:::::G    G::::::::G
       SSSSSS::::S       V:::::V V:::::V    G:::::G    GGGGG::::G
            S:::::S       V:::::V:::::V     G:::::G        G::::G
            S:::::S        V:::::::::V       G:::::G       G::::G
SSSSSSS     S:::::S         V:::::::V         G:::::GGGGGGGG::::G
S::::::SSSSSS:::::S          V:::::V           GG:::::::::::::::G
S:::::::::::::::SS            V:::V              GGG::::::GGG:::G
 SSSSSSSSSSSSSSS               VVV                  GGGGGG   GGGG                                                                                                                                                         
*/


import "@openzeppelin/contracts/utils/Strings.sol";
import "./Random.sol";

library SVG {
    using Strings for uint256;
    function head() public pure returns (bytes memory) {
        return abi.encodePacked(
            '<svg baseProfile="tiny" height="500" width="500" xmlns="http://www.w3.org/2000/svg">');
    }

    function tail() public pure returns (bytes memory){
        return '</svg>';
    }

    function bg(string calldata color) public pure returns (bytes memory){
        return abi.encodePacked('<path fill="',
                                color,
                                '" d="M0 0h500v500H0z"/>');
    }
    
    function text(string calldata hsl, 
                    string calldata fontSize, 
                    uint256 x, uint256 y,
                    string calldata text_content) public view returns (bytes memory){
                        string memory X= x.toString();
                        string memory Y= y.toString();
                        string memory range=(x+Random.randrange(10, x)).toString();
                        string memory speed= Random.randrange(10, x).toString();
                        bytes memory animation= abi.encodePacked('<animate attributeName="x" values="',
                                X,
                                ';', range, 
                                ';', X,
                                '" dur="',
                                speed,
                                's" repeatCount="indefinite"/></text>'
                                );

                        return abi.encodePacked('<text fill="hsl(',
                                hsl,
                                ')" font-size="',
                                fontSize,
                                '" x="', X,
                                '" y="', Y,
                                '">',
                                text_content,
                                animation
                                );   
    }

    function textMiddle(string calldata color, 
                    string calldata fontSize,
                    string calldata text_content) public pure returns (bytes memory){
                        return abi.encodePacked('<g><text id="tx" fill="',
                                color,
                                '" font-size="',
                                fontSize,
                                '" x="250" y="250" style="text-anchor: middle">',
                                text_content,
                                '<animate attributeName="y" values="200;300;200" dur="15s" repeatCount="indefinite"/></text><animateTransform attributeName="transform" begin="tx.click" dur="0.1s" type="scale" from="1" to="1.1" repeatCount="1"/></g>');   
    }
}
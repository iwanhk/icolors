// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
                                                                 dddddddd                                         
                                                                 d::::::d                                         
                                                                 d::::::d                                         
                                                                 d::::::d                                         
                                                                 d:::::d                                          
rrrrr   rrrrrrrrr   aaaaaaaaaaaaa  nnnn  nnnnnnnn        ddddddddd:::::d    ooooooooooo      mmmmmmm    mmmmmmm   
r::::rrr:::::::::r  a::::::::::::a n:::nn::::::::nn    dd::::::::::::::d  oo:::::::::::oo  mm:::::::m  m:::::::mm 
r:::::::::::::::::r aaaaaaaaa:::::an::::::::::::::nn  d::::::::::::::::d o:::::::::::::::om::::::::::mm::::::::::m
rr::::::rrrrr::::::r         a::::ann:::::::::::::::nd:::::::ddddd:::::d o:::::ooooo:::::om::::::::::::::::::::::m
 r:::::r     r:::::r  aaaaaaa:::::a  n:::::nnnn:::::nd::::::d    d:::::d o::::o     o::::om:::::mmm::::::mmm:::::m
 r:::::r     rrrrrrraa::::::::::::a  n::::n    n::::nd:::::d     d:::::d o::::o     o::::om::::m   m::::m   m::::m
 r:::::r           a::::aaaa::::::a  n::::n    n::::nd:::::d     d:::::d o::::o     o::::om::::m   m::::m   m::::m
 r:::::r          a::::a    a:::::a  n::::n    n::::nd:::::d     d:::::d o::::o     o::::om::::m   m::::m   m::::m
 r:::::r          a::::a    a:::::a  n::::n    n::::nd::::::ddddd::::::ddo:::::ooooo:::::om::::m   m::::m   m::::m
 r:::::r          a:::::aaaa::::::a  n::::n    n::::n d:::::::::::::::::do:::::::::::::::om::::m   m::::m   m::::m
 r:::::r           a::::::::::aa:::a n::::n    n::::n  d:::::::::ddd::::d oo:::::::::::oo m::::m   m::::m   m::::m
 rrrrrrr            aaaaaaaaaa  aaaa nnnnnn    nnnnnn   ddddddddd   ddddd   ooooooooooo   mmmmmm   mmmmmm   mmmmmm   
*/
library Random {
    function randrange(uint256 max, uint256 seed) view internal returns (uint256){
        if(max<=1){
            return 0;
        }
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, seed))) % max;
    }

    function randrange(uint256 min, uint256 max, uint256 seed) view internal returns(uint256){
        if(min> max){
            revert("Min > Max");
        }
        return min+ randrange(max-min, seed);
    }
}
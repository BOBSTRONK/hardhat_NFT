// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBase.sol";

contract BasicNFT is ERC721 {
    // what our token going to look like
    string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    // tokenID
    uint256 private s_tokenCounter;

    // calling ERC721 Constructor, naming the token Dogie with semple dog
    constructor() ERC721("Dogie", "DOG") {
        s_tokenCounter = 0;
    }

    // in order to create a new DOgs
    function mintNft() public returns (uint256) {
        // mint the token to whoever calls this function (owner of token)
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
        return s_tokenCounter;
    }

    function tokenURI(
        uint256 /*tokenId*/
    ) public view override returns (string memory) {
        // require(_exists(tokenId))
        return TOKEN_URI;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    // TokenURI what are the token going to look like:
    // URI: universal resource identifier
}

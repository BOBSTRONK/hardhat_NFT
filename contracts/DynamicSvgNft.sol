// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "base64-sol/base64.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DynamicSvgNft is ERC721 {
    // mint
    // store our SVG information somewhere
    // some logic to say "Show x Image" or "Show Y image", it's like switching the token URI

    uint256 private s_tokenCounter;
    string private i_lowImageURI;
    string private i_highImageUri;
    AggregatorV3Interface internal immutable i_priceFeed;

    string private constant base64EncodedSvgPrefix =
        "data:image/svg+xml;base64,";

    // assign each NFT thier own highvalue
    mapping(uint256 => int256) public s_tokenIdToHighValue;
    event createdNFT(uint256 indexed tokenId, int256 highValue);

    constructor(
        address priceFeedAddress,
        string memory lowSvg,
        string memory highSvg
    ) ERC721("Dynamic SVG NFT", "DSN") {
        s_tokenCounter = 0;
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
        i_lowImageURI = svgToImageURI(lowSvg);
        i_highImageUri = svgToImageURI(highSvg);
    }

    // encode Svg into a Base64 image url
    // we can do this off chain for gas optimization, but we can for sure do it here
    function svgToImageURI(
        string memory svg
    ) public pure returns (string memory) {
        // encode svg in base64 by adding the base64 encoding on chain
        string memory svgBase64Encoded = Base64.encode(
            // abi.encodePacked is basically how you concatenate strings
            // encoding together into it's bytes form, and type casting it to string and then to bytes.

            bytes(string(abi.encodePacked(svg)))
        );
        // we will stick this uri into our json
        // and we will base64 encode our json and that's going to be the URI that our token uses
        return
            string(abi.encodePacked(base64EncodedSvgPrefix, svgBase64Encoded));
    }

    // let minters choose the value they want to use.
    function mintNft(int256 highValue) public {
        // connect tokenCounter with highvalue
        s_tokenIdToHighValue[s_tokenCounter] = highValue;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
        emit createdNFT(s_tokenCounter, highValue);
    }

    // prefix of our TokenURI
    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(
            // If the owner exists, the result will be a non-zero Ethereum address;
            // otherwise, it will be the zero address.
            _ownerOf(tokenId) != address(0),
            "URI query for nonexistent token"
        );
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        string memory imageURI = i_lowImageURI;
        if (price >= s_tokenIdToHighValue[tokenId]) {
            imageURI = i_highImageUri;
        }

        // name() function of ERC721 which returns the name
        return
            string(
                // concatation again: it will be look like this: //"data:application/json;base64,Base64FormOfJson"
                abi.encodePacked(
                    _baseURI(),
                    // encode it in base64 format
                    Base64.encode(
                        // encode it in bytes
                        bytes(
                            // create a json string by concatenation
                            abi.encodePacked(
                                '{"name":"',
                                name(), // You can add whatever name here
                                '", "description":"An NFT that changes based on the Chainlink Feed", ',
                                '"attributes": [{"trait_type": "coolness", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}

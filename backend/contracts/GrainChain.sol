// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/eip/interface/IERC721Supply.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract GrainChain is ERC721URIStorage, IERC721Supply {
    uint256 private tokenIdCounter;

    event NFTCreated(uint256 tokenId);

    enum State {
        Idle,
        Ongoing,
        Distributed
    }

    struct Locate {
        string latitude;
        string longitude;
    }

    struct Lot_Token {
        uint256 tokenId;
        string grainName;
        address manufacturer;
        State status;
        int256 exceededTemp;
        Locate location;
        uint256 timestamp;
        uint256 weight;
        string image;
    }

    struct Distribution_Token {
        uint256 tokenId;
        address sender;
        uint256[] lotIds;
        string data;
        State state;
    }

    mapping(uint256 => Lot_Token) public allLots;
    mapping(uint256 => Distribution_Token) public allDistributions;
    mapping(uint256 => address) public ownerOfToken;

    constructor() ERC721("GrainNFT", "GNFT") {
        tokenIdCounter = 1;
    }

    function getLot(uint256 tokenId) public view returns (Lot_Token memory) {
        return allLots[tokenId];
    }

    function totalSupply() public view override returns (uint256) {
        return tokenIdCounter;
    }

    function createLotNFT(
        string memory _grainName,
        string memory _image,
        uint256 _weight,
        string memory _lati,
        string memory _longi
    ) public {
        _mint(msg.sender, tokenIdCounter);
        allLots[tokenIdCounter] = Lot_Token(
            tokenIdCounter,
            _grainName,
            msg.sender,
            State.Idle,
            0,
            Locate({latitude: _lati, longitude: _longi}),
            block.timestamp,
            _weight,
            _image
        );
        tokenIdCounter++;
    }

    function publishNFT(string memory _tokenURI) public {
        _setTokenURI(tokenIdCounter - 1, _tokenURI);

        emit NFTCreated(tokenIdCounter - 1);
    }

    function createOrderNFT(
        uint256[] memory _lotNFTIds,
        string memory _data
    ) public {
        require(
            _lotNFTIds.length > 0,
            "At least one lot must be included in the order"
        );

        uint256 orderId = tokenIdCounter;
        _mint(msg.sender, orderId);

        Distribution_Token memory newDistribution = Distribution_Token({
            tokenId: orderId,
            sender: msg.sender,
            lotIds: _lotNFTIds,
            data: _data,
            state: State.Ongoing
        });

        allDistributions[orderId] = newDistribution;
        tokenIdCounter++;
    }

    // Helper function to convert uint256 to string
    function uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

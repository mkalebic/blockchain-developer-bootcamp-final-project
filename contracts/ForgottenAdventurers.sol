// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "base64-sol/base64.sol";

/// @title Randomly generated adventurers from Azeroth
/// @author Matt Kalebic
/// @dev This contract uses Chainlink VRF (Verifiable Random Function) as a provably-fair and verifiable source of randomness for adventurers

/// This project was built out of nostalgia for the early years of World of Warcraft
/// Seeing how empty Azeroth is these days, I'm reminded of all the adventurers that logged off for the last time years ago
/// The randomly generated descriptions in this contract evoke a sense of reflection on the lore behind each Forgotten Adventurer

contract ForgottenAdventurers is ERC721URIStorage, VRFConsumerBase, Ownable {
    uint256 public tokenCounter;

    /// @dev Sets the maximum amount mintable
    uint256 public constant maxAvailable = 2007;
    /// @dev Sets the mint price in wei
    uint256 public constant price = 30000000000000000; // 0.03 ETH

    /// @dev Emitted when an adventurer is generated and the initial request for randomness has been made
    event requestedAdventurer(bytes32 indexed requestId, uint256 indexed tokenId); 
    /// @dev Emitted in the fulfillRandomness callback function after randomness has been received from the VRF
    event CreatedUnfinishedAdventurer(uint256 indexed tokenId, uint256 randomNumber);
    /// @dev Emitted after randomness has been used to generate an adventurer and finalize minting
    event CreatedAdventurer(uint256 indexed tokenId, string tokenURI); 
    
    /// @notice With every new request for randomness, Chainlink VRF generates a random number and cryptographic proof of how that number was determined
    /// @notice This proof is published and verified on-chain before it can be used by any consuming applications
    /// @notice You should expect a few minutes of delay between when a random number is requested vs. received based on network congestion and responsiveness

    /// @dev Requirements for the Chainlink VRF
    mapping(bytes32 => address) public requestIdToSender;
    mapping(uint256 => uint256) public tokenIdToRandomNumber;
    mapping(bytes32 => uint256) public requestIdToTokenId;
    bytes32 internal keyHash;
    uint256 internal fee;

    string[] private adventurerNames = [
        "Buckle",
        "Enysin",
        "Vallin",
        "Brunth", 
        "Celeste",
        "Brombr",
        "Flinte",
        "Rumdar"
    ];

    /// @dev Used to define a mapping between adventurer names and races
    mapping(string => string) races;

    string[] private classes = [
        "Warrior",
        "Paladin", 
        "Druid",
        "Rogue",
        "Priest",
        "Shaman",
        "Mage",
        "Warlock",
        "Hunter"
    ];

    string[] private suffixes = [
        ", Hand of A'dal",
        " of the Shattered Sun",
        " Jenkins",
        " the Patient",
        " the Hallowed"
    ];

    string[] private locations = [
        "Silverpine Forest",
        "Feralas",
        "Stormwind Bank",
        "Swamp of Sorrows",
        "Dun Morogh",
        "Ashenvale",
        "Wailing Caverns",
        "Winterspring",
        "Southshore",
        "Tarren Mill"
    ];

    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash, uint256 _fee) VRFConsumerBase(_VRFCoordinator, _LinkToken) ERC721("ForgottenAdventurers", "ADVNTR") Ownable() {

    tokenCounter = 0;
    keyHash = _keyhash;
    fee = _fee;

    /// @notice Full mapping between adventurer names and races
    races["Buckle"] = "Gnome";
    races["Enysin"] = "Night Elf";
    races["Vallin"] = "Human";
    races["Brunth"] = "Orc";
    races["Celeste"] = "Undead";
    races["Brombr"] = "Dwarf";
    races["Flinte"] = "Troll";
    races["Rumdar"] = "Tauren";
}    

    /// @notice Randomly chooses an adventurer's name using the pluckString() function 
    /// @param _randomNumber The random number received from Chainlink VRF
    /// @return String value for the randomly selected name
    function getName(uint256 _randomNumber) public view returns (string memory) {
        return pluckString(adventurerNames, true, _randomNumber);
    }

    /// @notice Randomly chooses an adventurer's race using the pluckString() function 
    /// @param _randomNumber The random number received from Chainlink VRF
    /// @return String value for the randomly selected race
    function getRace(uint256 _randomNumber) public view returns (string memory) {
        return races[pluckString(adventurerNames, false, _randomNumber)];
    }

    /// @notice Randomly chooses an adventurer's class using the pluckString() function 
    /// @param _randomNumber The random number received from Chainlink VRF
    /// @return String value for the randomly selected class
    function getClass(uint256 _randomNumber) public view returns (string memory) {
        return pluckString(classes, false, _randomNumber);
    }

    /// @notice Randomly chooses an adventurer's last seen location using the pluckString() function 
    /// @param _randomNumber The random number received from Chainlink VRF
    /// @return String value for the randomly selected location
    function getLastSeen(uint256 _randomNumber) public view returns (string memory) {
        return pluckString(locations, false, _randomNumber);
    }

    /// @notice Reusable function to randomly select a value from a list of options using Chainlink VRF
    /// @dev Inspired by Spells (for Wizards and other Adventurers) - MIT license
    /// https://etherscan.io/address/0x38e942948cea825992f105e0ec4a2ee9138afae4#code 
    /// @param _sourceArray Array containing all possible options to choose from
    /// @param _addSuffix Indicator for whether the attribute we're selecting a value for should be eligible for rare suffixes
    /// @param _randomNumber The random number received from Chainlink VRF
    /// @return String value for the randomly selected value, with rare suffix added if eligible
    function pluckString(string[] memory _sourceArray, bool _addSuffix, uint256 _randomNumber) internal view returns (string memory) {
        uint256 rand = _randomNumber;
        string memory output = _sourceArray[rand % _sourceArray.length];
        uint256 greatness = rand % 21;
        if (greatness > 13 && _addSuffix) {
            output = string(abi.encodePacked(output, suffixes[rand % suffixes.length]));
        }
        return output;
    }

    /// @notice Randomly chooses an adventurer's level using output from the Chainlink VRF
    /// @dev Taken from Chainlink's Best Practices document
    /// https://docs.chain.link/docs/chainlink-vrf-best-practices/#getting-a-random-number-within-a-range 
    /// @param _randomNumber The random number received from Chainlink VRF
    /// @return Randomly generated level between 1-60
    function getLevel(uint256 _randomNumber) public pure returns (string memory) {
        uint256 value = (_randomNumber % 60) + 1;
        return toString(value);
}
    /// @dev Inspired by OraclizeAPI's implementation - MIT license
    /// https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
    /// @return Number represented in string format
    function toString(uint256 value) internal pure returns (string memory) {

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

    /// @notice Usable by the owner to withdraw funds from the contract
    function withdraw() public payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /// @notice Get total number of NFT's minted
    /// @return Total number of NFT's minted
    function getTotalNFTsMintedSoFar() external view returns (uint256) {
      return tokenCounter;
  }

    /// @notice Get the maximum number of NFT's available
    /// @return Maximum number of NFT's available
  function getMaxAvailable() external pure returns (uint256) {
      return maxAvailable;
  }

    /// @notice Get the mint price
    /// @return Mint price for one NFT
  function getMintPrice() external pure returns (uint256) {
      return price;
  }

    /// @notice Requests a random number from the Chainlink VRF and creates a new token ID
    /// @dev Includes additional checks based on # of tokens minted and mint price
    /// @dev Inspired by Patrick Collins' RandomSVG.sol contract 
    /// https://github.com/PatrickAlphaC/all-on-chain-generated-nft/blob/main/contracts/RandomSVG.sol - MIT license
    /// @param _requestId ID of the request to Chainlink VRF
    /// @return _requestId of the request made to Chainlink VRF
    function create() public payable returns (bytes32 _requestId) {
        uint256 tokenId = tokenCounter;
        require(tokenId < maxAvailable, "All NFT's have already been minted");
        require(
            msg.value >= price,
            "Send moar ether"
        );
        _requestId = requestRandomness(keyHash, fee);
        requestIdToSender[_requestId] = msg.sender;
        requestIdToTokenId[_requestId] = tokenId;
        tokenCounter = tokenCounter + 1;
        emit requestedAdventurer(_requestId, tokenId);
    }

    
    /// @notice Receives a random number from the Chainlink VRF and uses that to finish generating an adventurer
    /// @dev It takes a few minutes for the Chainlink VRF to receive and respond to your request
    /// @param _tokenId ID of the newly-minted token
    function finishMint(uint256 _tokenId) public {
        require(bytes(tokenURI(_tokenId)).length <= 0, "tokenURI is already set!"); 
        require(tokenCounter > _tokenId, "TokenId has not been minted yet!");
        require(tokenIdToRandomNumber[_tokenId] > 0, "Need to wait for the Chainlink node to respond!");
        uint256 randomNumber = tokenIdToRandomNumber[_tokenId];
        string memory svg = generateSVG(randomNumber);
        string memory imageURI = svgToImageURI(svg);
        _setTokenURI(_tokenId, formatTokenURI(imageURI, _tokenId));
        emit CreatedAdventurer(_tokenId, svg);
    }

    /// @dev Customizes the Chainlink VRF callback function
    /// @param _requestId ID of the request to Chainlink VRF
    /// @param _randomNumber The random number received from Chainlink VRF
    function fulfillRandomness(bytes32 _requestId, uint256 _randomNumber) internal override {
        address nftOwner = requestIdToSender[_requestId];
        uint256 tokenId = requestIdToTokenId[_requestId];
        _safeMint(nftOwner, tokenId);
        tokenIdToRandomNumber[tokenId] = _randomNumber;
        emit CreatedUnfinishedAdventurer(tokenId, _randomNumber);
    }

    /// @notice Creates our image for the NFT
    /// @dev Dynamically generates an SVG using the trait creation functions defined above
    /// @param _randomNumber The random number received from Chainlink VRF
    /// @return finalSvg The assembled image for our NFT representing an Adventurer's information
    function generateSVG(uint256 _randomNumber) public view returns (string memory) {
        string[11] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">Name: ';

        parts[1] = getName(_randomNumber);

        parts[2] = '</text><text x="10" y="40" class="base"> Race: ';

        parts[3] = getRace(_randomNumber);

        parts[4] = '</text><text x="10" y="60" class="base"> Class: ';

        parts[5] = getClass(_randomNumber);

        parts[6] = '</text><text x="10" y="80" class="base"> Last Spotted: ';

        parts[7] = getLastSeen(_randomNumber);

        parts[8] = '</text><text x="10" y="100" class="base"> Level: ';

        parts[9] = getLevel(_randomNumber);

        parts[10] = '</text></svg>';

        string memory finalSvg = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8], parts[9], parts[10]));
        return finalSvg;
    }

    /// @dev Encodes our SVG so that it's viewable as an NFT
    /// @param _svg The SVG representing our Adventurer and their traits
    /// @return URI for the encoded image
    function svgToImageURI(string memory _svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(_svg))));
        return string(abi.encodePacked(baseURL,svgBase64Encoded));
    }

    /// @dev Finalizes the token URI and sets the format for descriptive information
    /// @param _imageURI URI for the encoded image
    /// @param _tokenId ID of the newly-minted token
    /// @return String representing our token URI
    function formatTokenURI(string memory _imageURI, uint256 _tokenId) public pure returns (string memory) {
        return string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',"Forgotten Adventurer #", toString(_tokenId) ,
                                '", "description":"A randomly generated Azerothian adventurer", "attributes":"", "image":"',_imageURI,'"}'
                            )
                        )
                    )
                )
            );
    }
    
  


}
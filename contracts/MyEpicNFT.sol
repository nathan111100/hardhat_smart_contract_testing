// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";

import "hardhat/console.sol";

// Our contract inherits from ERC721, which is the standard NFT contract!
contract MyEpicNFT is ERC721 {
  uint256 public totalSupply = 1000000;
  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;        
    uint hp;
    uint maxHp;
    uint attackDamage;
  }

  // The tokenId is the NFTs unique identifier, it's just a number that goes
  // 0, 1, 2, 3, etc.

  // imports a global counter 
  using Counters for Counters.Counter;
  //instantiates counter variable token_Ids = 0
  Counters.Counter private _tokenIds;
  Counters.Counter public numchars;
  CharacterAttributes[] defaultCharacters;

  address public owner;
  mapping(address => uint256) balances;

  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  mapping(address => uint256) public nftHolders;

  constructor (
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmgx
  ) ERC721("Heroes", "HERO") 
  {
    for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        attackDamage: characterAttackDmgx[i]
      }));
      numchars.increment();
      CharacterAttributes memory c = defaultCharacters[i];
      
      // Hardhat's use of console.log() allows up to 4 parameters in any order of following types: uint, string, bool, address
      console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
    }

    balances[msg.sender] = totalSupply;
    owner = msg.sender;

    _tokenIds.increment();
  }

  // Users would be able to hit this function and get their NFT based on the
  // characterId they send in!
  function mintCharacterNFT(uint _characterIndex) external {
    uint256 newItemId = _tokenIds.current();

    _safeMint(msg.sender, newItemId);

    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage
    });

    
    nftHolders[msg.sender] = newItemId;

    // Increment the tokenId for the next person that uses it.
    _tokenIds.increment();
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

    string memory strHp = Strings.toString(charAttributes.hp);
    string memory strMaxHp = Strings.toString(charAttributes.maxHp);
    string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

    string memory json = Base64.encode(
    abi.encodePacked(
      '{"name": "',
      charAttributes.name,
      ' -- NFT #: ',
      Strings.toString(_tokenId),
      '", "description": "This is a minted NFT", "image": "',
      charAttributes.imageURI,
      '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
      strAttackDamage,'} ]}'
    )
  );

    string memory output = string(
    abi.encodePacked("data:application/json;base64,", json)
    );
  
    return output;
  }

  function transfer(address to, uint256 amount) external {
      
        require(balances[msg.sender] >= amount, "Not enough tokens");

        balances[msg.sender] -= amount;
        balances[to] += amount;
  }
  function tokenbalance(address account) external view returns (uint256) {
        return balances[account];
  }

  function length() public view returns (uint256 size){
      return numchars.current();
  }

  function gethp(uint256 idx) public view returns (uint256 hp){

      CharacterAttributes memory charAttributes = nftHolderAttributes[idx];

      hp = charAttributes.hp;
      console.log(hp);
      return hp;
      
  }
  
}




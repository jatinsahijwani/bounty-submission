// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseNFT.sol";

contract MutantNFT is ERC721, Ownable {
    BaseNFT public nft1;
    BaseNFT public nft2;
    
    uint256 public totalSupply;
    mapping(uint256 => Trait) public mutantTraits;
    
    struct Trait {
        string species;
        string color;
        uint256 power;
    }
    
    constructor(address _nft1Address, address _nft2Address) 
        ERC721("MutantNFT", "MNFT")
        Ownable(msg.sender)
    {
        nft1 = BaseNFT(_nft1Address);
        nft2 = BaseNFT(_nft2Address);
    }
    
    function merge(uint256 token1Id, uint256 token2Id) public {
        require(nft1.ownerOf(token1Id) == msg.sender, "Not owner of token1");
        require(nft2.ownerOf(token2Id) == msg.sender, "Not owner of token2");
        
        // Burn original NFTs
        nft1.transferFrom(msg.sender, address(this), token1Id);
        nft2.transferFrom(msg.sender, address(this), token2Id);
        
        // Create new mutant NFT
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
        
        // Combine traits
        BaseNFT.Trait memory trait1 = nft1.getTraits(token1Id);
        BaseNFT.Trait memory trait2 = nft2.getTraits(token2Id);
        
        mutantTraits[totalSupply] = Trait({
            species: string(abi.encodePacked(trait1.species, "-", trait2.species)),
            color: string(abi.encodePacked(trait1.color, "-", trait2.color)),
            power: (trait1.power + trait2.power) * 2
        });
    }
    
    function getMutantTraits(uint256 tokenId) public view returns (Trait memory) {
        require(_exists(tokenId), "Token does not exist");
        return mutantTraits[tokenId];
    }
}
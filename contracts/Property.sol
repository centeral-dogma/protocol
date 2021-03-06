pragma solidity ^0.4.20;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./IProperty.sol";

contract Property is IProperty, ERC721Full("Property", "PROP"), Ownable {

    mapping (uint256 => address) private creators;
    mapping (address => uint256[]) private creatorTokens;
    mapping (uint256 => string) private variableMetadata;

    function mintWithTokenURI(address to, uint256 tokenId, string tokenURI) external onlyOwner returns (bool) {
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);

        creators[tokenId] = to;
        creatorTokens[to].push(tokenId);

        return true;
    }

    function burn(uint256 tokenId) external onlyOwner returns (bool) {
        remove(creators[tokenId], tokenId);
        delete creators[tokenId];
        
        _burn(ownerOf(tokenId), tokenId);
        return true;
    }

    function creatorOfToken(uint256 tokenId) external view returns (address) {
        return creators[tokenId];
    }

    function tokensByCreator(address creator) external view returns (uint256[]) {
        return creatorTokens[creator];
    }

    function variableMetadataURI(uint256 tokenId) external view returns (string) {
        return variableMetadata[tokenId];
    }

    function replaceVariableMetadataURI(uint256 tokenId, string metadataURI) external onlyOwner {
        variableMetadata[tokenId] = metadataURI;
    }

    function move(uint256 tokenId, address to) external onlyOwner returns (bool) {
        address from = ownerOf(tokenId);
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);
        return true;
    }

    function remove(address creator, uint256 tokenId) internal {
        uint256[] storage tokens = creatorTokens[creator];

        uint i = 0;
        while (tokens[i] != tokenId) {
            i++;
        }

        tokens[i] = tokens[tokens.length - 1];
        delete tokens[tokens.length - 1];
    }
}

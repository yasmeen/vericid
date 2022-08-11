// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {SoulMinter} from "./SoulMinter.sol";
import {Poap} from "./Poap.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Vericid is SoulMinter, Poap {
    address poapContractAddr = 0xa1eB40c284C5B44419425c4202Fa8DabFF31006b;

    struct Event {
        string name;
    }

    struct Recipe {
        string name;
        string metaURI;
        Event[] events;
    }

    Recipe[] recipes;

    function createNewRecipe(string name, Event[] events) returns (Recipe) {
        Recipe recipe;
        recipe.name = name;
        recipe.events = events;
        recipes.push(recipe);
        return recipe;
    }

    function walletHoldsToken(address memory _wallet, address memory _contract, uint256 tokenId) public view returns (bool) {
        return IERC721(_contract).balanceOf(_wallet) > 0;
    }

    function verifyPoaps(address addr, Recipe recipe) private view returns (bool) {
        for (uint256 i = 0; i < recipe.events.length; i++) {
            if (!walletHoldsToken(addr, poapContractAddr, recipe.events[i])) {
                return false;
            }
        }

        return true;
    }

    function grantSBT(address to, Recipe recipe) private {
        if (verifyPoaps(to, recipe)) {
            // SBT metadata is stored in ipfs
            mint(to, "ipfs://" + recipe.metaURI);
        }
    }
}
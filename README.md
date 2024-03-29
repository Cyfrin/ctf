> :exclamation: **IMPORTANT:** This codebase has not been audited, use at your own risk. 

# CTF

A minimal repo to help create capture the flag (CTF) challenges. 

# Getting Started

## Requirements

-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
    -   You'll know you've done it right if you can run `git --version`
-   [Foundry / Foundryup](https://github.com/gakonst/foundry)
    -   This will install `forge`, `cast`, and `anvil`
    -   You can test you've installed them right by running `forge --version` and get an output like: `forge 0.2.0 (f016135 2022-07-04T00:15:02.930499Z)`
    -   To get the latest of each, just run `foundryup`

## Quickstart

1. Install the package into your project.

```
forge install cyfrin/ctf --no-commit
```

or for Hardhat

```
npm install https://github.com/Cyfrin/ctf
```

2. Create a registration CTF contract

This will be the NFT contract, and the place you'll add challenge contracts to. 

*Note: If using hardhat, you'll need to import from `node_modules` instead of `lib`*

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {CTFRegistry} from "lib/ctf/src/protocol/CTFRegistry.sol";

contract SimpleCTFRegistry is CTFRegistry {
    constructor() CTFRegistry("Our CTF", "CTF") {}
}
```

3. Create a challenge contract

You'll need to add the following functions:

- `solveChallenge()` - This is the *optional* function that will be called when a user solves the challenge. The more important part, is that you need something to call `_updateAndRewardSolver()` which will update the user's NFT with the challenge they solved.
- `attribute()` - This is the attribute that will be shown on the NFT. 
- `description()` - This is the description that will be shown on the NFT.
- `specialImage()` - This is the image that will be shown on the NFT. There is a base NFT that will be used if this is left blank. 

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Challenge} from "lib/ctf/src/protocol/Challenge.sol";

contract SimpleCTFChallenge is Challenge {
    string constant BLANK_TWITTER_HANDLE = "";

    constructor(address registry) Challenge(registry) {}

    function solveChallenge() external {
        _updateAndRewardSolver(BLANK_TWITTER_HANDLE);
    }

    function attribute() external pure override returns (string memory) {
        return "Getting learned!";
    }

    function description() external pure override returns (string memory) {
        return "This is a simple CTF challenge.";
    }

    function specialImage() external pure returns (string memory) {
        return BLANK_TWITTER_HANDLE;
    }
}

```


4. Deploy, and add the contract to the registry

```javascript
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {SimpleCTFChallenge} from "../test/mocks/SimpleCTFChallenge.sol";
import {SimpleCTFRegistry} from "../test/mocks/SimpleCTFRegistry.sol";

contract MockDeploy is Script {
    function run() external {
        SimpleCTFRegistry registry = new SimpleCTFRegistry();
        SimpleCTFChallenge challenge = new SimpleCTFChallenge(address(registry));
        registry.addChallenge(address(challenge));
    }
}
```


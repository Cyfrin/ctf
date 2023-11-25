// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {CTFRegistry} from "../../src/protocol/CTFRegistry.sol";

contract SimpleCTFRegistry is CTFRegistry {
    constructor() CTFRegistry("Our CTF", "CTF") {}
}

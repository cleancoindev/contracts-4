/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/
pragma solidity 0.4.18;


/// @title ERC20 Token Interface
/// @dev see https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Interface.sol
contract ERC223 {
    uint public totalSupply;

    function name()  view public returns (string _name);
    function symbol()  view public returns (string _symbol);
    function decimals()  view public returns (uint8 _decimals);
    function totalSupply()  view public returns (uint256 _supply);
    function balanceOf(address who)  view public returns (uint);

    function transfer(
        address to,
        uint    value) public returns (bool ok);

    function transfer(
        address to,
        uint    value,
        bytes   data) public returns (bool ok);

    function transfer(
        address to,
        uint    value,
        bytes   data,
        string  customFallback) public returns (bool ok);

    event Transfer(
        address indexed from,
        address indexed to,
        uint            value,
        bytes   indexed data
    );
}
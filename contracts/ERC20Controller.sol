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

import "./ERC20.sol";
import "./MathUint.sol";

/// @title TokenTransferDelegate
/// @dev Acts as a middle man to transfer ERC20 tokens on behalf of different
/// versions of Loopring protocol to avoid ERC20 re-authorization.
/// @author Daniel Wang - <daniel@loopring.org>.
contract ERC20Controller  {
    using MathUint for uint;
    ////////////////////////////////////////////////////////////////////////////
    /// Structs                                                              ///
    ////////////////////////////////////////////////////////////////////////////

    struct Account {
        uint64      ethBalance;
        address[]   controlledAddresses;

    }
    ////////////////////////////////////////////////////////////////////////////
    /// Variables                                                            ///
    ////////////////////////////////////////////////////////////////////////////


    // A mapping from address to its control address.
    mapping(address => address) controlMap;

    mapping(address => Account) accountMap;


    ////////////////////////////////////////////////////////////////////////////
    /// Modifiers                                                            ///
    ////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////
    /// Events                                                               ///
    ////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////
    /// Public Functions                                                     ///
    ////////////////////////////////////////////////////////////////////////////

    function unbind() public {
        var controller = controlMap[msg.sender];
        require(controller != 0x0);
        unlinkAddress(msg.sender, controller);
    }

    function bindTo(address controller)
        public
    {
        require(controller != 0x0);

        address prevController = controlMap[msg.sender];
        require(controller != prevController);

        if (prevController != 0x0) {
            unlinkAddress(msg.sender, prevController);
        }

        linkAddress(msg.sender, controller);
    }

    function getBalance(
        address controller,
        address token
        )
        public
        returns (uint balance)
    {
        var addrs = accountMap[controller].controlledAddresses;
        var erc20 = ERC20(token);
        for (uint i = 0; i < addrs.length; i++) {
            balance += erc20.balanceOf(addrs[i]);
        }
    }

    function getSpendable(
        address controller,
        address token
        )
        public
        returns (uint spendable)
    {
        var addrs = accountMap[controller].controlledAddresses;
        var erc20 = ERC20(token);
        for (uint i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            uint balance = erc20.balanceOf(addr);
            uint allowance = erc20.allowance(addr, address(this));
            spendable += balance > allowance ? allowance : balance;
        }
    }

    function transfer(
        address token,
        address target,
        uint value
        )
        public
    {
        var addrs = accountMap[msg.sender].controlledAddresses;
        var erc20 = ERC20(token);
        uint remaining = value;
        for (uint i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            uint balance = erc20.balanceOf(addr);
            uint allowance = erc20.allowance(addr, address(this));
            uint spendable = balance > allowance ? allowance : balance;
            if (spendable >= remaining) {
                erc20.transferFrom(addr, target, remaining);
                return;
            } else {
                remaining -= spendable;
                erc20.transferFrom(addr, target, spendable);
            }
        }
    }  

    function unlinkAddress(
        address addr,
        address controller
        )
        internal
    {

    }


    function linkAddress(
        address addr,
        address controller
        )
        internal
    {

    }
}

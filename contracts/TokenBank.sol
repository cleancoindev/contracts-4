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
/// @dev see https://github.com/ethereum/EIPs/issues/20
/// @author Daniel Wang - <daniel@loopring.org>

library MathUint {
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
}

contract ERC20 {
    uint public totalSupply;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address who) view public returns (uint256);
    function allowance(address owner, address spender) view public returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
}

/// @title TokenTransferDelegate
/// @dev Acts as a middle man to transfer ERC20 tokens on behalf of different
/// versions of Loopring protocol to avoid ERC20 re-authorization.
/// @author Daniel Wang - <daniel@loopring.org>.
contract TokenTransferDelegate  {
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

    /// @dev Disable default function.
    function () payable public {
        revert();
    }

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

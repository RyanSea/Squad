// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/tokens/ERC20.sol";

import "openzeppelin/token/ERC721/IERC721Receiver.sol";

import "openzeppelin/utils/structs/EnumerableSet.sol";

import "forge-std/Test.sol";

/// @title Squad NFT Vault
contract Squad is ERC20 {

    /*///////////////////////////////////////////////////////////////
                              INITIALIZATION
    ///////////////////////////////////////////////////////////////*/ 

    using EnumerableSet for EnumerableSet.AddressSet;

    constructor(string memory _name, string memory _symbol) ERC20 (
        _name, 
        _symbol,
        18
    ) { }

    /// @notice member => share of ETH treasury
    mapping(address => uint) public eth_share;

    /// @notice member => share of NFT treasury
    mapping(address => uint) public nft_share;

    /// @notice members with ETH-based shares
    EnumerableSet.AddressSet private eth_members;

    /// @notice members with NFT-based shares
    EnumerableSet.AddressSet private nft_members;

    /// @notice ETH treasury
    /// note: needs to be saved for post-purchase accounting
    uint public treasury;

    /// @notice NFT treasury valuation
    uint public valuation;

    /*///////////////////////////////////////////////////////////////
                              CONTRIBUTION
    ///////////////////////////////////////////////////////////////*/
    
    /// @notice ETH contribution into the treasury
    function contribute() public payable {
        if (!eth_members.contains(msg.sender)) {
            eth_members.add(msg.sender);
        }

        eth_share[msg.sender] += msg.value;

        treasury += msg.value;

        _mint(msg.sender, msg.value);
    }

    /*///////////////////////////////////////////////////////////////
                                PURCHASE
    ///////////////////////////////////////////////////////////////*/

    /// @notice logic to execute on successful NFT purchase
    /// @param amount spent on purchase
    function buy(uint amount) public {
        // save treasury to memory
        uint _treasury = treasury;

        // percent of treasury spent 
        uint percent = _treasury * 1e18 / amount;

        // save set length to memory
        uint length = eth_members.length();

        // amount counter
        uint _amount;

        // memory save of member
        address member;

        // memory save of member's eth_share
        uint share;

        // amount spent from member's eth_share
        uint spent;

        for (uint i; i < length; ) {
            member = eth_members.at(i);

            share = eth_share[member];

            // note: this is imprecise, see logs
            spent = share * 1e18 / percent;

            _amount += spent;

            // add to nft_share
            nft_share[member] += spent;

            if (!nft_members.contains(member)) {
                nft_members.add(member);
            }

            share -= spent;

            eth_share[member] = share;

            if (share == 0) {
                eth_members.remove(member);

                unchecked { --length; }
            } else {
                unchecked { ++i; }
            }

        }

        // add amount to nft treasury valuation
        valuation += amount;

        // remove amount spent from treasury
        treasury -= amount;

        console.log("AMOUNT", amount);
        console.log("_AMOUNT", _amount);
        console.log("MATCHES", amount == _amount);
    }

    /*///////////////////////////////////////////////////////////////
                            VALUATION UPDATES
    ///////////////////////////////////////////////////////////////*/
    
    /// @notice mints shares to members based on member's share of NFT treasury & treasury appreciation amount
    /// @param amount net appreciated
    function appreciate(uint amount) public {
        // save valuation to memory
        uint _valuation = valuation;

        // percent valuation increased
        uint percent = _valuation * 1e18 / amount;

        // save set length to memory
        uint length = nft_members.length();

        // amount counter
        uint _amount;

        // memory save of member
        address member;

        // memory save of share
        uint share;

        // share appreciation
        uint appreciation;

        for (uint i; i < length; ) {
            member = nft_members.at(i);

            share = nft_share[member];

            appreciation = share * 1e18 / percent;

            _amount += appreciation;

            share += appreciation;

            nft_share[member] = share;

            // mint new shares 
            _mint(member, appreciation);

            unchecked { ++i; }
        }

        // save new valuation
        valuation += amount;

        console.log("AMOUNT", amount);
        console.log("_AMOUNT", _amount);
        console.log("MATCHES", amount == _amount);
    }

    /// @notice burns shares from members based on member's share of NFT treasury & treasury depriciation amount
    /// @param amount net depriciated
    function depriciate(uint amount) public {
        // save valuation to memory
        uint _valuation = valuation;

        // percent valuation increased
        uint percent = _valuation * 1e18 / amount;

        // save set length to memory
        uint length = nft_members.length();

        // amount counter
        uint _amount;

        // memory save of member
        address member;

        // memory save of share
        uint share;

        // share deprication
        uint depriciation;

        for (uint i; i < length; ) {
            member = nft_members.at(i);

            share = nft_share[member];

            depriciation = share * 1e18 / percent;

            _amount += depriciation;

            share -= depriciation;

            nft_share[member] = share;

            if (share == 0) {
                eth_members.remove(member);

                unchecked { --length; }
            } else {
                unchecked { ++i; }
            }

            _burn(member, depriciation);
        }

        // save new valuation
        valuation -= amount;

        console.log("AMOUNT", amount);
        console.log("_AMOUNT", _amount);
        console.log("MATCHES", amount == _amount);
    }

    /*///////////////////////////////////////////////////////////////
                              TRANSFER LOGIC
    ///////////////////////////////////////////////////////////////*/

    /*
     * TBD..
    */
}

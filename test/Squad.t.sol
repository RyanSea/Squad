// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//import "forge-std/Test.sol";

import "src/Squad.sol";

import "./utils/Utils.sol";

contract SquadTest is Test {

    Squad squad;

    Utils utils;

    address[] users;

    address ryan;

    address shelby;

    address thomas;

    address stewart;

    function setUp() public {
        // initialize squad
        squad = new Squad("Squad NFT Vault","SQUAD");

        // initialize members
        utils = new Utils();
        users = utils.createUsers(4);
        ryan = users[0];
        shelby = users[1];
        thomas = users[2];
        stewart = users[3];
    }

    function testSimpleSquad() public {

        // ROUND 1 //

        vm.prank(ryan);
        squad.contribute{ value : 1 ether }();

        vm.prank(shelby);
        squad.contribute{ value : 1 ether }();

        assertEq(squad.balanceOf(ryan), 1 ether);
        assertEq(squad.balanceOf(shelby), 1 ether);

        // PURCHASE //

        squad.buy(2 ether);

        // ROUND 2 //

        vm.prank(thomas);
        squad.contribute{ value : 3.3 ether }();

        vm.prank(stewart);
        squad.contribute{ value : 5.872 ether }();

        // DEPRICIATION //

        squad.depriciate(1 ether);

        // nft shares fall
        assertEq(squad.balanceOf(ryan), .5 ether);
        assertEq(squad.balanceOf(shelby), .5 ether);

        // eth shares stay the same
        assertEq(squad.balanceOf(thomas), 3.3 ether);
        assertEq(squad.balanceOf(stewart), 5.872 ether);

        // APPRECIATION //

        squad.appreciate(4 ether);

        // nft shares rise
        assertEq(squad.balanceOf(ryan), 2.5 ether);
        assertEq(squad.balanceOf(shelby), 2.5 ether);

        // eth shares stay the same
        assertEq(squad.balanceOf(thomas), 3.3 ether);
        assertEq(squad.balanceOf(stewart), 5.872 ether);

    }

    function testContribute() public {
        vm.prank(ryan);
        squad.contribute{ value : 1.1 ether }();
        assertEq(squad.balanceOf(ryan), 1.1 ether);

        vm.prank(shelby);
        squad.contribute{ value : 2.46 ether }();
        assertEq(squad.balanceOf(shelby), 2.46 ether);

        vm.prank(thomas);
        squad.contribute{ value : 5.83 ether }();
        assertEq(squad.balanceOf(thomas), 5.83 ether);

        vm.prank(stewart);
        squad.contribute{ value : 3.323 ether }();
        assertEq(squad.balanceOf(stewart), 3.323 ether);
    }

    function testPurchae() public {
        testContribute();

        squad.buy(2.5 ether);

        squad.appreciate(2 ether);

        squad.depriciate(2.555 ether);
    }
}

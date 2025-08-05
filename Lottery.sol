// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Lottery {
    address payable[] public players;
    address public manager;

    event PrizeReceived(uint256 amount, address indexed sender);
    event PrizeTransferred(uint256 amount, address indexed winner);

    mapping(address => uint256) public transactions;

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    receive() external payable {
        require(msg.value >= 0.1 ether, "Minimum 0.1 ETH to enter");
        players.push(payable(msg.sender));
        emit PrizeReceived(msg.value, msg.sender);
    }

    function getBalance() public view onlyManager returns (uint256) {
        return address(this).balance;
    }

    function random() internal view returns (uint256) {
        return uint256(
            keccak256(abi.encodePacked(block.prevrandao, block.timestamp, msg.sender))
        );
    }

    function pickWinner() public onlyManager {
        require(players.length >= 3, "At least 3 players required");

        uint256 index = random() % players.length;
        address payable winner = players[index];
        uint256 prize = address(this).balance;

        winner.transfer(prize);
        transactions[winner] = prize;

        emit PrizeTransferred(prize, winner);

        // Reset players
        players = new address payable ;
    }
}

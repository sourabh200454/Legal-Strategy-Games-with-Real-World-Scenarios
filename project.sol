// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LegalStrategyGame {

    address public owner;
    uint public gameId;
    mapping(uint => Game) public games;
    mapping(address => Player) public players;

    struct Game {
        uint id;
        address player1;
        address player2;
        string caseScenario;
        uint winner;  // 0 for undecided, 1 for player1, 2 for player2
    }

    struct Player {
        address playerAddress;
        string playerName;
        uint wins;
        uint losses;
    }

    event GameCreated(uint gameId, address player1, address player2);
    event GameResult(uint gameId, uint winner);
    event PlayerRegistered(address playerAddress, string playerName);

    constructor() {
        owner = msg.sender;
        gameId = 1;
    }

    // Modifier to ensure only the owner can call certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized.");
        _;
    }

    // Register a new player
    function registerPlayer(string memory name) public {
        require(bytes(players[msg.sender].playerName).length == 0, "Player already registered.");
        players[msg.sender] = Player(msg.sender, name, 0, 0);
        emit PlayerRegistered(msg.sender, name);
    }

    // Start a new game between two players
    function startGame(address player2, string memory caseScenario) public {
        require(bytes(players[msg.sender].playerName).length != 0, "You must be registered to play.");
        require(bytes(players[player2].playerName).length != 0, "The second player must be registered.");
        
        games[gameId] = Game(gameId, msg.sender, player2, caseScenario, 0);
        emit GameCreated(gameId, msg.sender, player2);
        gameId++;
    }

    // Submit the winner of a game
    function endGame(uint gameIdInput, uint winner) public {
        require(winner == 1 || winner == 2, "Winner must be 1 or 2.");
        Game storage game = games[gameIdInput];
        require(game.id != 0, "Game does not exist.");

        if (winner == 1) {
            players[game.player1].wins++;
            players[game.player2].losses++;
        } else {
            players[game.player2].wins++;
            players[game.player1].losses++;
        }

        game.winner = winner;
        emit GameResult(gameIdInput, winner);
    }

    // Get player stats
    function getPlayerStats(address player) public view returns (uint wins, uint losses) {
        return (players[player].wins, players[player].losses);
    }

    // Get game info
    function getGameInfo(uint _gameId) public view returns (address player1, address player2, string memory caseScenario, uint winner) {
        Game storage game = games[_gameId];
        return (game.player1, game.player2, game.caseScenario, game.winner);
    }
}

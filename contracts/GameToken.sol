// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameToken is ERC20, Ownable {

    uint256 immutable regWindow;
    Player[] playerList;

    struct Player {
        address player;
        string name;
        bool isRegistered;
        bool hasClaimed;
    }

    struct GameItem {
        address itemOwner;
        uint256 itemId;
        string itemName;
        uint256 amount;
    }

    mapping(address => Player) public players;
    mapping(uint256 => GameItem) public gameItems;


    event Registered(address player, bool success);
    event TokenBurnt(address owner, uint256 amount);
    event GameItemCreated(address creator, bytes32 itemId);
    event ItemRedeemed(address newOwner, uint256 itemId, string itemName);
    event AirdropClaimed(address player, uint256 amount);

    constructor(uint256 registrationTime)
        ERC20("GameToken", "GTK")
        Ownable()
    {
        regWindow = block.timestamp + registrationTime;
        _mint(owner(), 100000);
        Player storage _player = players[owner()];
        _player.isRegistered = true;
        setUpGameItems();
    }

    function setUpGameItems() private {
        gameItems[1] = GameItem(address(this), 1, "Car", 500);
        gameItems[2] = GameItem(address(this), 2, "Armor", 700);
        gameItems[3] = GameItem(address(this), 3, "Helmet", 300);
        gameItems[4] = GameItem(address(this), 4, "Sword", 200);
        gameItems[5] = GameItem(address(this), 5, "Archery",100);
    }

    modifier addressZeroCheck() {
        require(msg.sender != address(0), "Address Zero not allowed");
        _;
    }

    modifier isRegistered() {
        require(players[msg.sender].isRegistered, "You are not registered!");
        _;
    }

    function playerRegister(string memory _playerName) external {
        require(regWindow > block.timestamp, "Registration closed!");
        require(
            players[msg.sender].player == address(0),
            "You have registered!"
        );

        Player storage _player = players[msg.sender];
        _player.player = msg.sender;
        _player.name = _playerName;
        _player.isRegistered = true;

        playerList.push(_player);

        emit Registered(msg.sender, true);
    }

    function airdropToken() external onlyOwner {
        require(block.timestamp > regWindow, "Registration is still on!");

        Player[] memory _players = playerList;
        require(_players.length > 0, "No player has registered!");

        for (uint256 i; i < _players.length; i++) {
            approve(_players[i].player, 3000);
        }
    }

    function claimToken() external addressZeroCheck isRegistered {
        Player memory _player = players[msg.sender];
        require(!_player.hasClaimed, "Has claimed already!");

        uint256 amount = allowance(owner(), _player.player);

        require(transferFrom(
            owner(),
            _player.player,
            amount
        ), "Claim failed!");

        _player.hasClaimed = true;
        emit AirdropClaimed(_player.player, amount);
    }

    function balance() public view  isRegistered returns (uint256) {
        return balanceOf(msg.sender);
    }

    function transfer(address _to, uint256 _value) public override returns(bool) {
        require(players[_to].isRegistered, "Recipient is not a registered player!");
        return super.transfer(_to, _value);
    }

    function redeemItem(uint256 _itemId) external isRegistered {
        GameItem storage _gameItem = gameItems[_itemId];
        require(_gameItem.itemOwner != address(0), "Item does not exist!");
        require(balanceOf(msg.sender) >= _gameItem.amount, "Insuffucient balance");
        require(transfer(owner(), _gameItem.amount), "Redeem failed!");

        _gameItem.itemOwner = msg.sender;

        emit ItemRedeemed(msg.sender, _gameItem.itemId, _gameItem.itemName);
    }

    function burnToken(uint256 amount) external  {
        _burn(msg.sender, amount);
    }   
}

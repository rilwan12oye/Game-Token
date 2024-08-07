 
# DegenToken
DegenToken is a token that players in the game can earn and then exchange the token for rewards in the in-game store.

## Description
This is an ERC20 upgrade, which means it has all the functions of the ERC20 and also other functions.
It is meant to be a gamer token, where players of the game can earn the token, use the token for in-game transactions and also be able to send it to each other. Players can earn tokens, check their balance, transfer tokens, and redeem items on the platform with their tokens. 

Aside from the normal ERC20 functions, it has an additional 10 functions:

- playerRegister(string memory _playerName): allows players to register on the platform; without registration, players cannot access the platform.
- mint(address _to, uint256 _amount): allows the owner of the contract to mint (_amount) token to player (_to).
- playerP2PTransfer(address _recipient, uint256 _amount): allows players transfer tokens between themselves.
- playerCheckTokenBalance(): allows a user (msg.sender) to check his/her token balance in the contract.
- lockPlayerAccount(address player): allows owner/admin to lock the account of a player that offended or go against the rule of the platform.
- releasePlayerAccount(address player): allows owner/admin to unlock a player's account when forgiven.
- playerBurnsTheirToken(uint256 _amount): allows user (msg.sender) to burn (_amount) token no longer needed.
- ownerAddGameItem(string calldata _itemName, uint256 _amount): allows owner/admin to add items to the game-store for players to redeem.
- playerReedemItems(bytes32 _itemId): allows players to redeem items on the platform.
- getGameItem(bytes32 _itemId): returns an item with item id (_itemId).

## Getting Started
```git clone https://github.com/devpeeter/Avalanche_Degen-Game``` to clone the project. 
After cloning the github, do the following to get the code running on your computer.

- Inside the project directory, in the terminal type: npm i
- Open two terminals in your VS code or your preferred IDE
- In the first terminal type: ```npx hardhat``` compile to compile your contracts
- In the second terminal type: ```npx hardhat node``` to set up local nodes
- Go back to the first terminal and type: ```npx hardhat run --network localhost scripts/deploy.js``` to deploy your contract
- To interact with the functions in the contract, you can create another file in the script folder to write your interaction scripts.

## Authors
Rilwan Oyewole

## License
This project is licensed under the MIT License - see the LICENSE.md file for details







# AvalToken

GameToken, a Solidity program, is a gaming platform where users get rewarded for participating in the game. They get tokens, which can be transferred between players and used to redeem items in the game store.

# Description

This program is a simple contract written in Solidity, a programming language for developing smart contracts on the Ethereum blockchain. The smart contract imported the Openzeppelin ERC-20 and Ownable smart contract

```javascript
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
and from the ERC-20 contract implemented the transfer, mintToken and the burnToken functions.
```
The contract is a child contract to the OZ ERC-20 and the Ownable smart contract.

The smart contract has 7 functions which are explained below.
- playerRegister: This allows players to register within a stipulated time managed by a state variable
```javascript
uint256 immutable regWindow;
```
Once the ```block.timestamp``` is above the ```regWindow```, registration is closed and no one can register anymore.
- airdropToken: allows the owner of the contract to approve the registered users to spend a certain amount of token on his behalf. This token is only available to the players who were able to register. Each registered player gets a certain number of tokens.
- claimToken: allows registered players, who have been approved to spend a certain amount of token to claim their airdrop. Only the registered players approved can claim the token.
- balance: allows only registered users to check their balance.
- transfer: allows players to  transfer tokens to another registered player.
- redeemItem: allows players to redeem items in the game store. A player can buy items from the game store with their token.
  
# Getting Started

## Executing program

To run this program, you can use Remix, an online Solidity IDE. To get started, go to the Remix website at https://remix.ethereum.org/.

Once you are on the Remix website, create a new file by clicking on the "+" icon in the left-hand sidebar. Save the file with a .sol extension (e.g., GameToken.sol). Copy and paste the following code into the file:

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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
        Ownable(msg.sender)
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
```
To compile the code, click on the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler" option is set to "0.8.24" (or another compatible version), and then click on the "Compile GameToken.sol" button.

Once the code is compiled, you can deploy the contract by clicking the "Deploy & Run Transactions" tab in the left-hand sidebar. Select the "AvalToken" contract from the dropdown menu, and then click on the "Deploy" button.

Once the contract is deployed, you can interact with it the contract.

# Authors

Rilwan Oyewole

# License

This project is licensed under the MIT License - see the LICENSE.md file for details

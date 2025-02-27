![Dojo Starter](./assets/cover.png)

<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/mark-dark.svg">
  <img alt="Dojo logo" align="right" width="120" src=".github/mark-light.svg">
</picture>

<a href="https://x.com/ohayo_dojo">
<img src="https://img.shields.io/twitter/follow/dojostarknet?style=social"/>
</a>
<a href="https://github.com/dojoengine/dojo/stargazers">
<img src="https://img.shields.io/github/stars/dojoengine/dojo?style=social"/>
</a>

[![discord](https://img.shields.io/badge/join-dojo-green?logo=discord&logoColor=white)](https://discord.com/invite/dojoengine)
[![Telegram Chat][tg-badge]][tg-url]

[tg-badge]: https://img.shields.io/endpoint?color=neon&logo=telegram&label=chat&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fdojoengine
[tg-url]: https://t.me/dojoengine

# Beast Battle Game

A Dojo game where players attack a beast to earn XP and level up. The beast gets stronger as it levels up.

## Game Overview

In this game, players can:
- Register as a player
- Attack the main beast to deal damage and earn XP
- Level up their character to increase attack power
- Level up the beast after defeating it, making it stronger for the next round
- Earn BEAST tokens as rewards for attacking and leveling up

The beast gains more HP and attack power with each level, creating an increasingly challenging experience.

## Game Mechanics

- **Beast**: A central monster with HP, level, and attack power
- **Players**: Each player has XP, level, and attack power
- **Attacks**: Players can attack the beast with a cooldown period between attacks
- **XP System**: Players earn XP based on damage dealt to the beast
- **Leveling**: Both players and the beast can level up, increasing their stats
- **Token Rewards**: Players earn BEAST tokens for attacking and leveling up

## Getting Started

### Prerequisites

- [Dojo](https://github.com/dojoengine/dojo)
- [Scarb](https://docs.swmansion.com/scarb/)
- [Katana](https://github.com/dojoengine/dojo/tree/main/crates/katana)

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Build the project:
   ```
   scarb build
   ```

### Running the Game

1. Start a local Katana node:
   ```
   katana --disable-fee
   ```

2. Migrate the contracts:
   ```
   scarb run migrate
   ```

3. Initialize the game:
   ```
   scarb run initialize_game
   ```

4. Register as a player:
   ```
   scarb run register_player
   ```

5. Attack the beast:
   ```
   scarb run attack_beast
   ```

6. Level up the beast after defeating it:
   ```
   scarb run level_up_beast
   ```

7. Set the token contract address in the beast battle system:
   ```
   scarb run set_token_contract <TOKEN_CONTRACT_ADDRESS>
   ```

8. Authorize the beast battle system to mint tokens:
   ```
   scarb run authorize_minter <BEAST_BATTLE_CONTRACT_ADDRESS>
   ```

## Game Commands

- `initialize_game`: Set up the game with initial settings and spawn the first beast
- `register_player`: Register a new player in the game
- `attack_beast`: Attack the beast to deal damage and earn XP
- `level_up_beast`: Level up the beast after it has been defeated
- `player_level_up`: Check if a player can level up (this happens automatically during attacks)
- `set_token_contract`: Set the token contract address in the beast battle system
- `authorize_minter`: Authorize a contract to mint tokens

## Token Rewards

The game includes an ERC20 token called BEAST that rewards players for participating:

- **Attack Rewards**: Players earn tokens each time they attack the beast
- **Level Up Rewards**: Players earn additional tokens when they level up
- **Token Utility**: BEAST tokens can be used for future game features (e.g., purchasing items, upgrading abilities)

## Testing

Run the tests with:
```
sozo test
```

The test suite includes tests for:
- Game initialization
- Player registration
- Beast attacks
- Leveling mechanics
- Error conditions

## Project Structure

- `models.cairo`: Defines the data models for the game
- `systems/beast_battle.cairo`: Implements the game logic
- `systems/token.cairo`: Implements the ERC20 token contract
- `tests/test_beast_battle.cairo`: Contains tests for the game
- `lib.cairo`: Exports the modules

## License

This project is licensed under the MIT License - see the LICENSE file for details.

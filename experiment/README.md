# Movement Game in Dojo

A simple movement-based game built with Dojo where players can move around a 2D world, avoid obstacles, and manage their health.

## Game Overview

In this game, players can:
- Move in four directions (up, down, left, right)
- Encounter obstacles that may cause damage
- Manage a limited number of moves per turn
- Heal themselves

## Game Models

The game uses the following models:

- **Position**: Tracks a player's position in the world
- **Player**: Stores player data like health, direction, and remaining moves
- **World**: Defines the boundaries of the game world
- **Obstacle**: Represents objects in the world that can damage players
- **GameConfig**: Stores game configuration values

## Game Systems

The game has two main systems:

1. **Movement System**:
   - `initialize()`: Sets up the game world with default values
   - `move(direction)`: Moves the player in a specified direction
   - `reset_moves()`: Resets a player's moves to the maximum allowed
   - `spawn_obstacle(position, is_solid, damage)`: Creates obstacles in the world

2. **Player System**:
   - `create_player(starting_position)`: Creates a new player at the specified position
   - `heal_player(amount)`: Heals the player by a specified amount

## How to Play

1. First, initialize the game world:
   ```
   initialize()
   ```

2. Create a player at a starting position:
   ```
   create_player(Vec2 { x: 10, y: 10 })
   ```

3. Move your player around:
   ```
   move(Direction::Up)
   move(Direction::Right)
   move(Direction::Down)
   move(Direction::Left)
   ```

4. When you run out of moves, reset them:
   ```
   reset_moves()
   ```

5. If your health gets low, heal yourself:
   ```
   heal_player(20)
   ```

## Game Rules

- Players start with 100 health
- Players have a limited number of moves per turn (default: 5)
- Obstacles can be solid (blocking movement) or passable
- Hitting an obstacle causes damage based on the obstacle's damage value
- Players cannot move outside the world boundaries

## Development

This game is built using the Dojo framework for Cairo. To build and run the game:

1. Install Dojo and Scarb
2. Build the project:
   ```
   scarb build
   ```

3. Run tests:
   ```
   scarb test
   ```

4. Deploy to a Dojo world:
   ```
   sozo migrate
   ```

Enjoy playing! 
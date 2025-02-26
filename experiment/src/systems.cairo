use starknet::ContractAddress;
use starknet::get_caller_address;

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use movement_game::models::{
    Direction, Vec2, Position, Player, World, Obstacle, GameConfig, GAME_CONFIG_ID, WORLD_ID
};

// Define events for our game
#[derive(Copy, Drop, Serde)]
#[dojo::event]
struct PlayerMoved {
    #[key]
    player: ContractAddress,
    old_position: Vec2,
    new_position: Vec2,
    direction: Direction
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
struct PlayerDamaged {
    #[key]
    player: ContractAddress,
    damage: u8,
    health_remaining: u8
}

// Define the interface for our movement system
#[starknet::interface]
trait IMovementSystem<TContractState> {
    fn initialize(self: @TContractState);
    fn move(ref self: TContractState, direction: Direction);
    fn reset_moves(ref self: TContractState);
    fn spawn_obstacle(ref self: TContractState, position: Vec2, is_solid: bool, damage: u8);
}

// Implement the movement system
#[dojo::contract]
mod movement_system {
    use super::*;

    #[abi(embed_v0)]
    impl MovementSystem of IMovementSystem<ContractState> {
        // Initialize the game world with default values
        fn initialize(self: @ContractState) {
            let world = self.world();
            
            // Initialize the game config
            let config = GameConfig {
                id: GAME_CONFIG_ID,
                max_moves_per_turn: 5,
                damage_per_obstacle: 10
            };
            world.write_model(@config);
            
            // Initialize the world boundaries
            let game_world = World {
                id: WORLD_ID,
                width: 100,
                height: 100
            };
            world.write_model(@game_world);
        }
        
        // Move the player in a direction
        fn move(ref self: ContractState, direction: Direction) {
            let world = self.world();
            let player = get_caller_address();
            
            // Read player data
            let mut player_data: Player = world.read_model(player);
            let mut position: Position = world.read_model(player);
            
            // Check if player has moves remaining
            assert(player_data.moves_remaining > 0, 'No moves remaining');
            
            // Store old position for event
            let old_position = position.vec;
            
            // Calculate new position based on direction
            let mut new_position = calculate_new_position(position.vec, direction);
            
            // Check world boundaries
            let game_world: World = world.read_model(WORLD_ID);
            new_position = check_world_boundaries(new_position, game_world);
            
            // Update player position
            position.vec = new_position;
            
            // Check for obstacles at the new position
            let obstacles = check_for_obstacles(world, new_position);
            
            // Apply damage if player hit an obstacle
            if obstacles.damage > 0 {
                let config: GameConfig = world.read_model(GAME_CONFIG_ID);
                let damage = obstacles.damage * config.damage_per_obstacle;
                
                // Ensure we don't underflow health
                if player_data.health <= damage {
                    player_data.health = 0;
                } else {
                    player_data.health -= damage;
                }
                
                // Emit damage event
                world.emit_event(
                    @PlayerDamaged { 
                        player, 
                        damage, 
                        health_remaining: player_data.health 
                    }
                );
                
                // If obstacle is solid, don't move there
                if obstacles.is_solid {
                    position.vec = old_position;
                }
            }
            
            // Update player direction and consume a move
            player_data.direction = direction;
            player_data.moves_remaining -= 1;
            
            // Write updated models back to the world
            world.write_model(@player_data);
            world.write_model(@position);
            
            // Emit movement event
            world.emit_event(
                @PlayerMoved { 
                    player, 
                    old_position, 
                    new_position: position.vec, 
                    direction 
                }
            );
        }
        
        // Reset player's moves to max_moves_per_turn
        fn reset_moves(ref self: ContractState) {
            let world = self.world();
            let player = get_caller_address();
            
            // Read player data and game config
            let mut player_data: Player = world.read_model(player);
            let config: GameConfig = world.read_model(GAME_CONFIG_ID);
            
            // Reset moves
            player_data.moves_remaining = config.max_moves_per_turn;
            
            // Write updated player data
            world.write_model(@player_data);
        }
        
        // Spawn an obstacle at a specific position
        fn spawn_obstacle(ref self: ContractState, position: Vec2, is_solid: bool, damage: u8) {
            let world = self.world();
            
            // Generate a unique ID for the obstacle
            let obstacle_id = world.uuid();
            
            // Create and write the obstacle
            let obstacle = Obstacle {
                id: obstacle_id.try_into().unwrap(),
                position,
                is_solid,
                damage
            };
            
            world.write_model(@obstacle);
        }
    }
}

// Helper function to calculate new position based on direction
fn calculate_new_position(current: Vec2, direction: Direction) -> Vec2 {
    match direction {
        Direction::Up => Vec2 { x: current.x, y: current.y + 1 },
        Direction::Down => Vec2 { x: current.x, y: current.y - 1 },
        Direction::Left => Vec2 { x: current.x - 1, y: current.y },
        Direction::Right => Vec2 { x: current.x + 1, y: current.y },
    }
}

// Helper function to check world boundaries
fn check_world_boundaries(position: Vec2, world: World) -> Vec2 {
    let mut result = position;
    
    // Ensure x is within bounds
    if position.x >= world.width {
        result.x = world.width - 1;
    }
    
    // Ensure y is within bounds
    if position.y >= world.height {
        result.y = world.height - 1;
    }
    
    result
}

// Helper function to check for obstacles at a position
// Returns a dummy obstacle with damage and is_solid flags set
fn check_for_obstacles(world: IWorldDispatcher, position: Vec2) -> Obstacle {
    // In a real implementation, we would query all obstacles and check if any
    // are at the given position. For simplicity, we'll return a dummy obstacle.
    
    // This is a placeholder - in a real implementation, you would:
    // 1. Query all obstacles
    // 2. Check if any are at the given position
    // 3. Return the obstacle if found, or a dummy with no damage if not
    
    Obstacle {
        id: 0,
        position,
        is_solid: false,
        damage: 0
    }
} 
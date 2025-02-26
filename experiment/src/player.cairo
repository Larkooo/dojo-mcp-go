use starknet::ContractAddress;
use starknet::get_caller_address;

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use movement_game::models::{
    Direction, Vec2, Position, Player, GameConfig, GAME_CONFIG_ID
};

// Define events for player system
#[derive(Copy, Drop, Serde)]
#[dojo::event]
struct PlayerCreated {
    #[key]
    player: ContractAddress,
    position: Vec2,
    health: u8
}

// Define the interface for our player system
#[starknet::interface]
trait IPlayerSystem<TContractState> {
    fn create_player(ref self: TContractState, starting_position: Vec2);
    fn heal_player(ref self: TContractState, amount: u8);
}

// Implement the player system
#[dojo::contract]
mod player_system {
    use super::*;

    #[abi(embed_v0)]
    impl PlayerSystem of IPlayerSystem<ContractState> {
        // Create a new player at the specified position
        fn create_player(ref self: ContractState, starting_position: Vec2) {
            let world = self.world();
            let player_address = get_caller_address();
            
            // Read game config for max moves
            let config: GameConfig = world.read_model(GAME_CONFIG_ID);
            
            // Create player data
            let player_data = Player {
                player: player_address,
                health: 100,
                direction: Direction::Right,
                moves_remaining: config.max_moves_per_turn
            };
            
            // Create player position
            let position = Position {
                player: player_address,
                vec: starting_position
            };
            
            // Write models to the world
            world.write_model(@player_data);
            world.write_model(@position);
            
            // Emit player created event
            world.emit_event(
                @PlayerCreated { 
                    player: player_address, 
                    position: starting_position, 
                    health: 100 
                }
            );
        }
        
        // Heal the player by a specified amount
        fn heal_player(ref self: ContractState, amount: u8) {
            let world = self.world();
            let player_address = get_caller_address();
            
            // Read player data
            let mut player_data: Player = world.read_model(player_address);
            
            // Add health, capped at 100
            let new_health = player_data.health + amount;
            if new_health > 100 {
                player_data.health = 100;
            } else {
                player_data.health = new_health;
            }
            
            // Write updated player data
            world.write_model(@player_data);
        }
    }
} 
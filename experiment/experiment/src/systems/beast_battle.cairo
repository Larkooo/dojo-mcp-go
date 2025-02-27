use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
use crate::models::{Beast, Player, BattleResult, GameSettings};
use dojo::model::{ModelStorage, ModelValueStorage, Model};
use dojo::event::EventStorage;
use dojo::world::{WorldStorage, WorldStorageTrait};

// Define the interface for our beast battle system
#[starknet::interface]
pub trait IBeastBattle<T> {
    fn initialize_game(ref self: T);
    fn register_player(ref self: T);
    fn attack_beast(ref self: T);
    fn level_up_beast(ref self: T);
    fn get_player_stats(self: @T) -> Player;
    fn get_beast_stats(self: @T) -> Beast;
}

// Define custom events
#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct PlayerRegistered {
    #[key]
    pub player: ContractAddress,
    pub level: u32,
    pub attack_power: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct BeastAttacked {
    #[key]
    pub player: ContractAddress,
    pub damage_dealt: u32,
    pub xp_earned: u32,
    pub beast_hp_remaining: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct PlayerLeveledUp {
    #[key]
    pub player: ContractAddress,
    pub old_level: u32,
    pub new_level: u32,
    pub new_attack_power: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct BeastLeveledUp {
    #[key]
    pub id: u32,
    pub old_level: u32,
    pub new_level: u32,
    pub new_hp: u32,
    pub new_attack_power: u32,
}

// Constants
const BEAST_ID: u32 = 1;
const GAME_SETTINGS_ID: u32 = 1;

// Implement the beast battle system
#[dojo::contract]
pub mod beast_battle {
    use super::{
        IBeastBattle, Beast, Player, BattleResult, GameSettings, 
        PlayerRegistered, BeastAttacked, PlayerLeveledUp, BeastLeveledUp,
        BEAST_ID, GAME_SETTINGS_ID
    };
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use dojo::model::{ModelStorage, ModelValueStorage, Model};
    use dojo::event::EventStorage;
    use dojo::world::{WorldStorage, WorldStorageTrait};

    #[abi(embed_v0)]
    impl BeastBattleImpl of IBeastBattle<ContractState> {
        // Initialize the game with default settings and spawn the initial beast
        fn initialize_game(ref self: ContractState) {
            let mut world = self.world_default();
            
            // Create default game settings
            let settings = GameSettings {
                id: GAME_SETTINGS_ID,
                attack_cooldown: 60, // 60 seconds cooldown between attacks
                xp_per_damage: 10, // 10 XP per point of damage
                level_up_xp_base: 100, // Base XP required for level up
                level_up_xp_factor: 50, // Additional XP per level
                beast_hp_per_level: 100, // HP increase per beast level
                beast_attack_per_level: 5, // Attack increase per beast level
                player_attack_per_level: 3, // Attack increase per player level
            };
            
            // Create the initial beast at level 1
            let beast = Beast {
                id: BEAST_ID,
                hp: 100,
                max_hp: 100,
                level: 1,
                attack_power: 5,
            };
            
            // Write models to the world
            world.write_model(@settings);
            world.write_model(@beast);
        }
        
        // Register a new player in the game
        fn register_player(ref self: ContractState) {
            let mut world = self.world_default();
            let player_address = get_caller_address();
            
            // Check if player already exists
            let existing_player: Player = world.read_model(player_address);
            assert(existing_player.level == 0, 'Player already registered');
            
            // Create a new player at level 1
            let player = Player {
                player: player_address,
                xp: 0,
                level: 1,
                attack_power: 10,
                last_attack_time: 0, // No attacks yet
            };
            
            // Write player to the world
            world.write_model(@player);
            
            // Emit player registered event
            world.emit_event(@PlayerRegistered { 
                player: player_address, 
                level: player.level, 
                attack_power: player.attack_power 
            });
        }
        
        // Allow a player to attack the beast
        fn attack_beast(ref self: ContractState) {
            let mut world = self.world_default();
            let player_address = get_caller_address();
            let current_time = get_block_timestamp();
            
            // Get player data
            let mut player: Player = world.read_model(player_address);
            assert(player.level > 0, 'Player not registered');
            
            // Get beast data
            let mut beast: Beast = world.read_model(BEAST_ID);
            assert(beast.hp > 0, 'Beast is defeated');
            
            // Get game settings
            let settings: GameSettings = world.read_model(GAME_SETTINGS_ID);
            
            // Check cooldown
            if player.last_attack_time > 0 {
                let time_since_last_attack = current_time - player.last_attack_time;
                assert(
                    time_since_last_attack >= settings.attack_cooldown, 
                    'Attack on cooldown'
                );
            }
            
            // Calculate damage based on player's attack power
            let damage = player.attack_power;
            let beast_hp_before = beast.hp;
            
            // Update beast HP (ensure it doesn't go below 0)
            if damage >= beast.hp {
                beast.hp = 0;
            } else {
                beast.hp -= damage;
            }
            
            // Calculate XP earned
            let xp_earned = damage * settings.xp_per_damage;
            player.xp += xp_earned;
            
            // Check if player levels up
            let xp_needed_for_level_up = settings.level_up_xp_base + 
                (player.level * settings.level_up_xp_factor);
                
            if player.xp >= xp_needed_for_level_up {
                let old_level = player.level;
                player.level += 1;
                player.xp -= xp_needed_for_level_up;
                player.attack_power += settings.player_attack_per_level;
                
                // Emit player level up event
                world.emit_event(@PlayerLeveledUp { 
                    player: player_address, 
                    old_level, 
                    new_level: player.level, 
                    new_attack_power: player.attack_power 
                });
            }
            
            // Update player's last attack time
            player.last_attack_time = current_time;
            
            // Create battle result record
            let battle_result = BattleResult {
                player: player_address,
                timestamp: current_time,
                damage_dealt: damage,
                xp_earned,
                beast_hp_before,
                beast_hp_after: beast.hp,
            };
            
            // Write updated models to the world
            world.write_model(@player);
            world.write_model(@beast);
            world.write_model(@battle_result);
            
            // Emit beast attacked event
            world.emit_event(@BeastAttacked { 
                player: player_address, 
                damage_dealt: damage, 
                xp_earned, 
                beast_hp_remaining: beast.hp 
            });
        }
        
        // Level up the beast when it's defeated
        fn level_up_beast(ref self: ContractState) {
            let mut world = self.world_default();
            
            // Get beast data
            let mut beast: Beast = world.read_model(BEAST_ID);
            assert(beast.hp == 0, 'Beast not defeated yet');
            
            // Get game settings
            let settings: GameSettings = world.read_model(GAME_SETTINGS_ID);
            
            // Store old level for event
            let old_level = beast.level;
            
            // Level up the beast
            beast.level += 1;
            
            // Calculate new stats based on level
            beast.max_hp = beast.level * settings.beast_hp_per_level;
            beast.hp = beast.max_hp; // Fully heal the beast
            beast.attack_power = beast.level * settings.beast_attack_per_level;
            
            // Write updated beast to the world
            world.write_model(@beast);
            
            // Emit beast level up event
            world.emit_event(@BeastLeveledUp { 
                id: BEAST_ID, 
                old_level, 
                new_level: beast.level, 
                new_hp: beast.hp, 
                new_attack_power: beast.attack_power 
            });
        }
        
        // Get a player's stats
        fn get_player_stats(self: @ContractState) -> Player {
            let world = self.world_default();
            let player_address = get_caller_address();
            
            // Return player data
            world.read_model(player_address)
        }
        
        // Get the beast's stats
        fn get_beast_stats(self: @ContractState) -> Beast {
            let world = self.world_default();
            
            // Return beast data
            world.read_model(BEAST_ID)
        }
    }
    
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        // Helper function to get the world with the default namespace
        fn world_default(self: @ContractState) -> WorldStorage {
            self.world(@"dojo_starter")
        }
    }
} 
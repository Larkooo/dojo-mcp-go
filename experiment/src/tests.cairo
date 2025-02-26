#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    use movement_game::models::{
        Direction, Vec2, Position, Player, World, Obstacle, GameConfig, GAME_CONFIG_ID, WORLD_ID
    };
    use movement_game::systems::{
        IMovementSystemDispatcher, IMovementSystemDispatcherTrait, movement_system
    };
    use movement_game::player::{
        IPlayerSystemDispatcher, IPlayerSystemDispatcherTrait, player_system
    };

    // Helper function to set up the test environment
    fn setup() -> (IWorldDispatcher, IMovementSystemDispatcher, IPlayerSystemDispatcher, ContractAddress) {
        // Create a test world
        let world = spawn_test_world();
        
        // Deploy the movement system contract
        let movement_contract = deploy_contract(
            world, movement_system::TEST_CLASS_HASH.try_into().unwrap(), array![].span()
        );
        
        // Deploy the player system contract
        let player_contract = deploy_contract(
            world, player_system::TEST_CLASS_HASH.try_into().unwrap(), array![].span()
        );
        
        // Create dispatcher instances
        let movement_system = IMovementSystemDispatcher { contract_address: movement_contract };
        let player_system = IPlayerSystemDispatcher { contract_address: player_contract };
        
        // Set up a test player address
        let player_address = contract_address_const::<0x1>();
        
        (world, movement_system, player_system, player_address)
    }

    #[test]
    #[available_gas(10000000)]
    fn test_initialize_game() {
        let (world, movement_system, _, _) = setup();
        
        // Initialize the game world
        movement_system.initialize();
        
        // Check that the game config was created with expected values
        let config: GameConfig = world.read_model(GAME_CONFIG_ID);
        assert(config.max_moves_per_turn == 5, 'Wrong max moves');
        assert(config.damage_per_obstacle == 10, 'Wrong damage multiplier');
        
        // Check that the world was created with expected boundaries
        let game_world: World = world.read_model(WORLD_ID);
        assert(game_world.width == 100, 'Wrong world width');
        assert(game_world.height == 100, 'Wrong world height');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_create_player() {
        let (world, movement_system, player_system, player_address) = setup();
        
        // Initialize the game world
        movement_system.initialize();
        
        // Create a player at position (10, 10)
        let starting_position = Vec2 { x: 10, y: 10 };
        
        // We need to impersonate the player address for this test
        starknet::testing::set_caller_address(player_address);
        
        player_system.create_player(starting_position);
        
        // Check that the player was created with expected values
        let player: Player = world.read_model(player_address);
        assert(player.health == 100, 'Wrong player health');
        assert(player.direction == Direction::Right, 'Wrong player direction');
        assert(player.moves_remaining == 5, 'Wrong moves remaining');
        
        // Check that the player position was set correctly
        let position: Position = world.read_model(player_address);
        assert(position.vec.x == 10, 'Wrong player x position');
        assert(position.vec.y == 10, 'Wrong player y position');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_player_movement() {
        let (world, movement_system, player_system, player_address) = setup();
        
        // Initialize the game world
        movement_system.initialize();
        
        // Create a player at position (10, 10)
        let starting_position = Vec2 { x: 10, y: 10 };
        
        // We need to impersonate the player address for this test
        starknet::testing::set_caller_address(player_address);
        
        player_system.create_player(starting_position);
        
        // Move the player right
        movement_system.move(Direction::Right);
        
        // Check that the player moved right
        let position: Position = world.read_model(player_address);
        assert(position.vec.x == 11, 'Wrong x after moving right');
        assert(position.vec.y == 10, 'Y should not change');
        
        // Check that the player's direction was updated
        let player: Player = world.read_model(player_address);
        assert(player.direction == Direction::Right, 'Wrong direction');
        assert(player.moves_remaining == 4, 'Wrong moves remaining');
        
        // Move the player up
        movement_system.move(Direction::Up);
        
        // Check that the player moved up
        let position: Position = world.read_model(player_address);
        assert(position.vec.x == 11, 'X should not change');
        assert(position.vec.y == 11, 'Wrong y after moving up');
        
        // Check that the player's direction was updated
        let player: Player = world.read_model(player_address);
        assert(player.direction == Direction::Up, 'Wrong direction');
        assert(player.moves_remaining == 3, 'Wrong moves remaining');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_world_boundaries() {
        let (world, movement_system, player_system, player_address) = setup();
        
        // Initialize the game world with small boundaries for testing
        movement_system.initialize();
        
        // Manually set the world boundaries to be smaller for this test
        let small_world = World {
            id: WORLD_ID,
            width: 20,
            height: 20
        };
        world.write_model(@small_world);
        
        // Create a player at the edge of the world
        let edge_position = Vec2 { x: 19, y: 19 };
        
        // We need to impersonate the player address for this test
        starknet::testing::set_caller_address(player_address);
        
        player_system.create_player(edge_position);
        
        // Try to move the player right (beyond the boundary)
        movement_system.move(Direction::Right);
        
        // Check that the player was stopped at the boundary
        let position: Position = world.read_model(player_address);
        assert(position.vec.x == 19, 'Should stop at boundary x');
        assert(position.vec.y == 19, 'Y should not change');
        
        // Try to move the player up (beyond the boundary)
        movement_system.move(Direction::Up);
        
        // Check that the player was stopped at the boundary
        let position: Position = world.read_model(player_address);
        assert(position.vec.x == 19, 'X should not change');
        assert(position.vec.y == 19, 'Should stop at boundary y');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_reset_moves() {
        let (world, movement_system, player_system, player_address) = setup();
        
        // Initialize the game world
        movement_system.initialize();
        
        // Create a player
        let starting_position = Vec2 { x: 10, y: 10 };
        
        // We need to impersonate the player address for this test
        starknet::testing::set_caller_address(player_address);
        
        player_system.create_player(starting_position);
        
        // Use up some moves
        movement_system.move(Direction::Right);
        movement_system.move(Direction::Right);
        movement_system.move(Direction::Right);
        
        // Check that moves were consumed
        let player: Player = world.read_model(player_address);
        assert(player.moves_remaining == 2, 'Wrong moves remaining');
        
        // Reset moves
        movement_system.reset_moves();
        
        // Check that moves were reset to max
        let player: Player = world.read_model(player_address);
        assert(player.moves_remaining == 5, 'Moves not reset correctly');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_heal_player() {
        let (world, movement_system, player_system, player_address) = setup();
        
        // Initialize the game world
        movement_system.initialize();
        
        // Create a player
        let starting_position = Vec2 { x: 10, y: 10 };
        
        // We need to impersonate the player address for this test
        starknet::testing::set_caller_address(player_address);
        
        player_system.create_player(starting_position);
        
        // Manually reduce player health for testing
        let mut player: Player = world.read_model(player_address);
        player.health = 50;
        world.write_model(@player);
        
        // Heal the player
        player_system.heal_player(20);
        
        // Check that health was increased
        let player: Player = world.read_model(player_address);
        assert(player.health == 70, 'Health not increased correctly');
        
        // Test healing beyond max health
        player_system.heal_player(50);
        
        // Check that health was capped at 100
        let player: Player = world.read_model(player_address);
        assert(player.health == 100, 'Health should be capped at 100');
    }
} 
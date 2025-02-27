use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
use dojo::world::{WorldStorageTrait};
use dojo_cairo_test::{
    spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef,
    WorldStorageTestTrait,
};

use experiment::systems::beast_battle::{
    beast_battle, IBeastBattleDispatcher, IBeastBattleDispatcherTrait,
    PlayerRegistered, BeastAttacked, PlayerLeveledUp, BeastLeveledUp
};
use experiment::models::{
    Beast, Player, BattleResult, GameSettings,
    m_Beast, m_Player, m_BattleResult, m_GameSettings
};

// Constants used in tests
const BEAST_ID: u32 = 1;
const GAME_SETTINGS_ID: u32 = 1;

// Define the namespace and resources for testing
fn namespace_def() -> NamespaceDef {
    NamespaceDef {
        namespace: "ns",
        resources: [
            TestResource::Model(m_Beast::TEST_CLASS_HASH),
            TestResource::Model(m_Player::TEST_CLASS_HASH),
            TestResource::Model(m_BattleResult::TEST_CLASS_HASH),
            TestResource::Model(m_GameSettings::TEST_CLASS_HASH),
            TestResource::Event(beast_battle::e_PlayerRegistered::TEST_CLASS_HASH),
            TestResource::Event(beast_battle::e_BeastAttacked::TEST_CLASS_HASH),
            TestResource::Event(beast_battle::e_PlayerLeveledUp::TEST_CLASS_HASH),
            TestResource::Event(beast_battle::e_BeastLeveledUp::TEST_CLASS_HASH),
            TestResource::Contract(beast_battle::TEST_CLASS_HASH),
        ]
            .span(),
    }
}

// Define contract permissions
fn contract_defs() -> Span<ContractDef> {
    [
        ContractDefTrait::new(@"ns", @"beast_battle")
            .with_writer_of([dojo::utils::bytearray_hash(@"ns")].span())
    ]
        .span()
}

#[test]
#[available_gas(30000000)]
fn test_initialize_game() {
    // Initialize test environment
    let caller = starknet::contract_address_const::<0x0>();
    let ndef = namespace_def();
    let mut world = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs());

    // Get the beast_battle system
    let (beast_battle_addr, _) = world.dns(@"beast_battle").unwrap();
    let beast_battle_system = IBeastBattleDispatcher { contract_address: beast_battle_addr };

    // Initialize the game
    beast_battle_system.initialize_game();

    // Check that game settings were properly initialized
    let settings: GameSettings = world.read_model(GAME_SETTINGS_ID);
    assert(settings.id == GAME_SETTINGS_ID, 'Wrong settings ID');
    assert(settings.attack_cooldown == 60, 'Wrong attack cooldown');
    assert(settings.xp_per_damage == 10, 'Wrong XP per damage');
    assert(settings.level_up_xp_base == 100, 'Wrong level up XP base');
    assert(settings.level_up_xp_factor == 50, 'Wrong level up XP factor');
    assert(settings.beast_hp_per_level == 100, 'Wrong beast HP per level');
    assert(settings.beast_attack_per_level == 5, 'Wrong beast attack per level');
    assert(settings.player_attack_per_level == 3, 'Wrong player attack per level');

    // Check that beast was properly initialized
    let beast: Beast = world.read_model(BEAST_ID);
    assert(beast.id == BEAST_ID, 'Wrong beast ID');
    assert(beast.hp == 100, 'Wrong beast HP');
    assert(beast.max_hp == 100, 'Wrong beast max HP');
    assert(beast.level == 1, 'Wrong beast level');
    assert(beast.attack_power == 5, 'Wrong beast attack power');
}

#[test]
#[available_gas(30000000)]
fn test_register_player() {
    // Initialize test environment
    let caller = starknet::contract_address_const::<0x0>();
    let ndef = namespace_def();
    let mut world = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs());

    // Get the beast_battle system
    let (beast_battle_addr, _) = world.dns(@"beast_battle").unwrap();
    let beast_battle_system = IBeastBattleDispatcher { contract_address: beast_battle_addr };

    // Initialize the game
    beast_battle_system.initialize_game();

    // Set caller as the player
    starknet::testing::set_contract_address(caller);

    // Register the player
    beast_battle_system.register_player();

    // Check that player was properly registered
    let player: Player = world.read_model(caller);
    assert(player.player == caller, 'Wrong player address');
    assert(player.xp == 0, 'Wrong player XP');
    assert(player.level == 1, 'Wrong player level');
    assert(player.attack_power == 10, 'Wrong player attack power');
    assert(player.last_attack_time == 0, 'Wrong last attack time');
}

#[test]
#[available_gas(30000000)]
#[should_panic(expected: ('Player already registered', 'ENTRYPOINT_FAILED'))]
fn test_register_player_already_registered() {
    // Initialize test environment
    let caller = starknet::contract_address_const::<0x0>();
    let ndef = namespace_def();
    let mut world = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs());

    // Get the beast_battle system
    let (beast_battle_addr, _) = world.dns(@"beast_battle").unwrap();
    let beast_battle_system = IBeastBattleDispatcher { contract_address: beast_battle_addr };

    // Initialize the game
    beast_battle_system.initialize_game();

    // Set caller as the player
    starknet::testing::set_contract_address(caller);

    // Register the player
    beast_battle_system.register_player();

    // Try to register again (should fail)
    beast_battle_system.register_player();
}

#[test]
#[available_gas(30000000)]
fn test_attack_beast() {
    // Initialize test environment
    let caller = starknet::contract_address_const::<0x0>();
    let ndef = namespace_def();
    let mut world = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs());

    // Get the beast_battle system
    let (beast_battle_addr, _) = world.dns(@"beast_battle").unwrap();
    let beast_battle_system = IBeastBattleDispatcher { contract_address: beast_battle_addr };

    // Initialize the game
    beast_battle_system.initialize_game();

    // Set caller as the player
    starknet::testing::set_contract_address(caller);

    // Register the player
    beast_battle_system.register_player();

    // Get initial beast HP
    let initial_beast: Beast = world.read_model(BEAST_ID);
    
    // Set block timestamp for testing
    starknet::testing::set_block_timestamp(1000);

    // Attack the beast
    beast_battle_system.attack_beast();

    // Check that beast HP was reduced
    let beast: Beast = world.read_model(BEAST_ID);
    assert(beast.hp == initial_beast.hp - 10, 'Beast HP not reduced correctly');

    // Check that player earned XP
    let player: Player = world.read_model(caller);
    assert(player.xp == 10 * 10, 'Player did not earn correct XP');
    assert(player.last_attack_time == 1000, 'Last attack time not updated');

    // Check that battle result was recorded
    let battle_result: BattleResult = world.read_model((caller, 1000));
    assert(battle_result.player == caller, 'Wrong player in battle result');
    assert(battle_result.timestamp == 1000, 'Wrong timestamp in battle result');
    assert(battle_result.damage_dealt == 10, 'Wrong damage in battle result');
    assert(battle_result.xp_earned == 100, 'Wrong XP in battle result');
    assert(battle_result.beast_hp_before == initial_beast.hp, 'Wrong beast HP before');
    assert(battle_result.beast_hp_after == beast.hp, 'Wrong beast HP after');
}

#[test]
#[available_gas(30000000)]
#[should_panic(expected: ('Attack on cooldown', 'ENTRYPOINT_FAILED'))]
fn test_attack_beast_cooldown() {
    // Initialize test environment
    let caller = starknet::contract_address_const::<0x0>();
    let ndef = namespace_def();
    let mut world = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs());

    // Get the beast_battle system
    let (beast_battle_addr, _) = world.dns(@"beast_battle").unwrap();
    let beast_battle_system = IBeastBattleDispatcher { contract_address: beast_battle_addr };

    // Initialize the game
    beast_battle_system.initialize_game();

    // Set caller as the player
    starknet::testing::set_contract_address(caller);

    // Register the player
    beast_battle_system.register_player();
    
    // Set block timestamp for testing
    starknet::testing::set_block_timestamp(1000);

    // Attack the beast
    beast_battle_system.attack_beast();

    // Try to attack again immediately (should fail due to cooldown)
    beast_battle_system.attack_beast();
}

#[test]
#[available_gas(30000000)]
fn test_level_up_beast() {
    // Initialize test environment
    let caller = starknet::contract_address_const::<0x0>();
    let ndef = namespace_def();
    let mut world = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs());

    // Get the beast_battle system
    let (beast_battle_addr, _) = world.dns(@"beast_battle").unwrap();
    let beast_battle_system = IBeastBattleDispatcher { contract_address: beast_battle_addr };

    // Initialize the game
    beast_battle_system.initialize_game();

    // Set beast HP to 0 to simulate defeat
    let mut beast: Beast = world.read_model(BEAST_ID);
    beast.hp = 0;
    world.write_model_test(@beast);

    // Level up the beast
    beast_battle_system.level_up_beast();

    // Check that beast was properly leveled up
    let new_beast: Beast = world.read_model(BEAST_ID);
    assert(new_beast.level == 2, 'Beast level not increased');
    assert(new_beast.hp == 200, 'Beast HP not increased');
    assert(new_beast.max_hp == 200, 'Beast max HP not increased');
    assert(new_beast.attack_power == 10, 'Beast attack not increased');
}

#[test]
#[available_gas(30000000)]
#[should_panic(expected: ('Beast not defeated yet', 'ENTRYPOINT_FAILED'))]
fn test_level_up_beast_not_defeated() {
    // Initialize test environment
    let caller = starknet::contract_address_const::<0x0>();
    let ndef = namespace_def();
    let mut world = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs());

    // Get the beast_battle system
    let (beast_battle_addr, _) = world.dns(@"beast_battle").unwrap();
    let beast_battle_system = IBeastBattleDispatcher { contract_address: beast_battle_addr };

    // Initialize the game
    beast_battle_system.initialize_game();

    // Try to level up the beast without defeating it (should fail)
    beast_battle_system.level_up_beast();
}

#[test]
#[available_gas(30000000)]
fn test_player_level_up() {
    // Initialize test environment
    let caller = starknet::contract_address_const::<0x0>();
    let ndef = namespace_def();
    let mut world = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs());

    // Get the beast_battle system
    let (beast_battle_addr, _) = world.dns(@"beast_battle").unwrap();
    let beast_battle_system = IBeastBattleDispatcher { contract_address: beast_battle_addr };

    // Initialize the game
    beast_battle_system.initialize_game();

    // Set caller as the player
    starknet::testing::set_contract_address(caller);

    // Register the player
    beast_battle_system.register_player();

    // Set player XP to just below level up threshold
    let mut player: Player = world.read_model(caller);
    player.xp = 99; // Need 100 + (1 * 50) = 150 XP to level up
    world.write_model_test(@player);

    // Set block timestamp for testing
    starknet::testing::set_block_timestamp(1000);

    // Attack the beast to earn XP and trigger level up
    beast_battle_system.attack_beast();

    // Check that player leveled up
    let new_player: Player = world.read_model(caller);
    assert(new_player.level == 2, 'Player level not increased');
    assert(new_player.attack_power == 13, 'Player attack not increased');
    assert(new_player.xp == 49, 'Player XP not reset correctly');
}

#[test]
#[available_gas(30000000)]
fn test_get_player_stats() {
    // Initialize test environment
    let caller = starknet::contract_address_const::<0x0>();
    let ndef = namespace_def();
    let mut world = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs());

    // Get the beast_battle system
    let (beast_battle_addr, _) = world.dns(@"beast_battle").unwrap();
    let beast_battle_system = IBeastBattleDispatcher { contract_address: beast_battle_addr };

    // Initialize the game
    beast_battle_system.initialize_game();

    // Set caller as the player
    starknet::testing::set_contract_address(caller);

    // Register the player
    beast_battle_system.register_player();

    // Get player stats
    let player_stats = beast_battle_system.get_player_stats();

    // Check that stats match
    assert(player_stats.player == caller, 'Wrong player address');
    assert(player_stats.level == 1, 'Wrong player level');
    assert(player_stats.xp == 0, 'Wrong player XP');
    assert(player_stats.attack_power == 10, 'Wrong player attack power');
}

#[test]
#[available_gas(30000000)]
fn test_get_beast_stats() {
    // Initialize test environment
    let caller = starknet::contract_address_const::<0x0>();
    let ndef = namespace_def();
    let mut world = spawn_test_world([ndef].span());
    world.sync_perms_and_inits(contract_defs());

    // Get the beast_battle system
    let (beast_battle_addr, _) = world.dns(@"beast_battle").unwrap();
    let beast_battle_system = IBeastBattleDispatcher { contract_address: beast_battle_addr };

    // Initialize the game
    beast_battle_system.initialize_game();

    // Get beast stats
    let beast_stats = beast_battle_system.get_beast_stats();

    // Check that stats match
    assert(beast_stats.id == BEAST_ID, 'Wrong beast ID');
    assert(beast_stats.level == 1, 'Wrong beast level');
    assert(beast_stats.hp == 100, 'Wrong beast HP');
    assert(beast_stats.max_hp == 100, 'Wrong beast max HP');
    assert(beast_stats.attack_power == 5, 'Wrong beast attack power');
} 
use starknet::{ContractAddress};

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Moves {
    #[key]
    pub player: ContractAddress,
    pub remaining: u8,
    pub last_direction: Option<Direction>,
    pub can_move: bool,
}

#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct DirectionsAvailable {
    #[key]
    pub player: ContractAddress,
    pub directions: Array<Direction>,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Position {
    #[key]
    pub player: ContractAddress,
    pub vec: Vec2,
}


#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug)]
pub enum Direction {
    Left,
    Right,
    Up,
    Down,
}


#[derive(Copy, Drop, Serde, IntrospectPacked, Debug)]
pub struct Vec2 {
    pub x: u32,
    pub y: u32,
}


impl DirectionIntoFelt252 of Into<Direction, felt252> {
    fn into(self: Direction) -> felt252 {
        match self {
            Direction::Left => 1,
            Direction::Right => 2,
            Direction::Up => 3,
            Direction::Down => 4,
        }
    }
}

impl OptionDirectionIntoFelt252 of Into<Option<Direction>, felt252> {
    fn into(self: Option<Direction>) -> felt252 {
        match self {
            Option::None => 0,
            Option::Some(d) => d.into(),
        }
    }
}

#[generate_trait]
impl Vec2Impl of Vec2Trait {
    fn is_zero(self: Vec2) -> bool {
        if self.x - self.y == 0 {
            return true;
        }
        false
    }

    fn is_equal(self: Vec2, b: Vec2) -> bool {
        self.x == b.x && self.y == b.y
    }
}

#[cfg(test)]
mod tests {
    use super::{Vec2, Vec2Trait};

    #[test]
    fn test_vec_is_zero() {
        assert(Vec2Trait::is_zero(Vec2 { x: 0, y: 0 }), 'not zero');
    }

    #[test]
    fn test_vec_is_equal() {
        let position = Vec2 { x: 420, y: 0 };
        assert(position.is_equal(Vec2 { x: 420, y: 0 }), 'not equal');
    }
}

// Beast Battle Game Models

// Beast model to represent the main beast in the game
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Beast {
    #[key]
    pub id: u32, // Using a single beast with ID 1
    pub hp: u32,
    pub max_hp: u32,
    pub level: u32,
    pub attack_power: u32,
}

// Player model to track player stats
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Player {
    #[key]
    pub player: ContractAddress,
    pub xp: u32,
    pub level: u32,
    pub attack_power: u32,
    pub last_attack_time: u64, // To implement cooldown between attacks
}

// BattleResult model to track player attacks on the beast
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct BattleResult {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub timestamp: u64,
    pub damage_dealt: u32,
    pub xp_earned: u32,
    pub beast_hp_before: u32,
    pub beast_hp_after: u32,
}

// Game settings model to store global game parameters
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct GameSettings {
    #[key]
    pub id: u32, // Using ID 1 for the single game settings
    pub attack_cooldown: u64, // Cooldown time between attacks in seconds
    pub xp_per_damage: u32, // XP earned per point of damage dealt
    pub level_up_xp_base: u32, // Base XP required for level up
    pub level_up_xp_factor: u32, // Factor to multiply by level for level up XP
    pub beast_hp_per_level: u32, // HP increase per beast level
    pub beast_attack_per_level: u32, // Attack increase per beast level
    pub player_attack_per_level: u32, // Attack increase per player level
}

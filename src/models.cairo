use starknet::ContractAddress;
use dojo::world::IWorldDispatcher;
use dojo::database::introspect::Introspect;

#[derive(Copy, Drop, Serde, PartialEq)]
enum Direction {
    Up,
    Down,
    Left,
    Right
}

#[derive(Copy, Drop, Serde)]
struct Vec2 {
    x: u32,
    y: u32
}

impl Vec2Introspect of Introspect<Vec2> {
    #[inline(always)]
    fn size() -> Option<usize> {
        Option::Some(2)
    }

    fn layout() -> dojo::database::introspect::Layout {
        dojo::database::introspect::Layout::Struct(
            array![
                dojo::database::introspect::FieldLayout {
                    selector: selector!("x"),
                    layout: dojo::database::introspect::Introspect::<u32>::layout()
                },
                dojo::database::introspect::FieldLayout {
                    selector: selector!("y"),
                    layout: dojo::database::introspect::Introspect::<u32>::layout()
                },
            ]
                .span()
        )
    }

    #[inline(always)]
    fn ty() -> dojo::database::introspect::Ty {
        dojo::database::introspect::Ty::Struct(
            dojo::database::introspect::Struct {
                name: 'Vec2',
                attrs: array![].span(),
                children: array![
                    dojo::database::introspect::Member {
                        name: 'x',
                        attrs: array![].span(),
                        ty: dojo::database::introspect::Introspect::<u32>::ty()
                    },
                    dojo::database::introspect::Member {
                        name: 'y',
                        attrs: array![].span(),
                        ty: dojo::database::introspect::Introspect::<u32>::ty()
                    },
                ]
                    .span()
            }
        )
    }
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Position {
    #[key]
    player: ContractAddress,
    vec: Vec2
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Player {
    #[key]
    player: ContractAddress,
    health: u8,
    direction: Direction,
    moves_remaining: u8
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct World {
    #[key]
    id: u32,
    width: u32,
    height: u32
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Obstacle {
    #[key]
    id: u32,
    position: Vec2,
    is_solid: bool,
    damage: u8
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct GameConfig {
    #[key]
    id: u32,
    max_moves_per_turn: u8,
    damage_per_obstacle: u8
}

// Constants for game configuration
const GAME_CONFIG_ID: u32 = 1;
const WORLD_ID: u32 = 1; 
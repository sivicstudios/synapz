#[cfg(test)]
mod tests {
    use core::starknet::ContractAddress;
    use starknet::{testing, contract_address_const};
    use dojo_cairo_test::WorldStorageTestTrait;
    use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
    use dojo::world::{WorldStorageTrait, WorldStorage};
    use dojo::world::{world, Resource, IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::event::Event;
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef,
    };
    use core::array::{ArrayTrait, SpanTrait};
    use core::result::ResultTrait;
    use synapz::interfaces::community::{
        ICommunityGameModeDispatcher, ICommunityGameModeDispatcherTrait,
    };
    use synapz::models::community::{
        Game, m_Game, GameStatus, Trivia, m_Trivia, TriviaInfo, m_TriviaInfo, Question, m_Question,
        Player, m_Player, Answer, m_Answer, PlayerBoard, m_PlayerBoard,
    };
    use synapz::models::shared::{ResourceCounter, m_ResourceCounter};
    use synapz::events::community::{
        GameCreated, GameStarted, GameEnded, NextQuestion, QuestionAdded, AnswerSubmitted,
        PlayerJoined, TriviaCreated, e_GameCreated, e_GameStarted, e_GameEnded, e_NextQuestion,
        e_QuestionAdded, e_AnswerSubmitted, e_PlayerJoined, e_TriviaCreated,
    };
    use synapz::systems::actions::{actions};
    use synapz::errors::shared::{
        NOT_IN_GAME, ALREADY_ANSWERED, ALREADY_IN_GAME, NO_QUESTIONS, INVALID_GAME_STATUS,
        NOT_IN_LOBBY, TIME_EXPIRED, UNAUTHORIZED,
    };

    const OWNER_ADDRESS: felt252 = 'owner';
    const PLAYER1_ADDRESS: felt252 = 'player1';
    const PLAYER2_ADDRESS: felt252 = 'player2';
    const NON_OWNER_ADDRESS: felt252 = 'non_owner';
    const NON_PLAYER_ADDRESS: felt252 = 'non_player';

    const TRIVIA_COUNTER: felt252 = 'trivia_counter';
    const GAME_COUNTER: felt252 = 'game_id';

    const Q1_TEXT: felt252 = 'What is Cairo?';
    const Q1_OPTIONS: felt252 = 'Lang, Place, Person';
    const Q1_ANSWER: u8 = 0;
    const Q1_TIME: u8 = 30;

    const Q2_TEXT: felt252 = 'What is Dojo?';
    const Q2_OPTIONS: felt252 = 'Framework, Game, Tool';
    const Q2_ANSWER: u8 = 0;
    const Q2_TIME: u8 = 20;


    // --- Helper Functions ---

    fn owner() -> ContractAddress {
        contract_address_const::<OWNER_ADDRESS>()
    }

    fn player1() -> ContractAddress {
        contract_address_const::<PLAYER1_ADDRESS>()
    }

    fn player2() -> ContractAddress {
        contract_address_const::<PLAYER2_ADDRESS>()
    }

    fn non_owner() -> ContractAddress {
        contract_address_const::<NON_OWNER_ADDRESS>()
    }

    fn non_player() -> ContractAddress {
        contract_address_const::<NON_PLAYER_ADDRESS>()
    }

    // Defines the resources (models, contracts, events) for the test world
    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "synapz",
            resources: array![
                TestResource::Model(m_Game::TEST_CLASS_HASH),
                TestResource::Model(m_Trivia::TEST_CLASS_HASH),
                TestResource::Model(m_TriviaInfo::TEST_CLASS_HASH),
                TestResource::Model(m_Question::TEST_CLASS_HASH),
                TestResource::Model(m_Player::TEST_CLASS_HASH),
                TestResource::Model(m_Answer::TEST_CLASS_HASH),
                TestResource::Model(m_PlayerBoard::TEST_CLASS_HASH),
                TestResource::Model(m_ResourceCounter::TEST_CLASS_HASH),
                TestResource::Contract(actions::TEST_CLASS_HASH),
                TestResource::Event(e_GameCreated::TEST_CLASS_HASH),
                TestResource::Event(e_GameStarted::TEST_CLASS_HASH),
                TestResource::Event(e_GameEnded::TEST_CLASS_HASH),
                TestResource::Event(e_NextQuestion::TEST_CLASS_HASH),
                TestResource::Event(e_QuestionAdded::TEST_CLASS_HASH),
                TestResource::Event(e_AnswerSubmitted::TEST_CLASS_HASH),
                TestResource::Event(e_PlayerJoined::TEST_CLASS_HASH),
                TestResource::Event(e_TriviaCreated::TEST_CLASS_HASH),
            ]
                .span(),
        };
        ndef
    }

    // Defines contract write permissions for the test world
    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"synapz", @"actions") // Match namespace and contract name
                .with_writer_of([dojo::utils::bytearray_hash(@"synapz")].span())
        ]
            .span()
    }

    // Sets up the test environment: world, contract dispatcher, initial state
    fn test_setup() -> (WorldStorage, ICommunityGameModeDispatcher) {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());

        // Initialize resource counters needed by the contract
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"actions").unwrap();
        let game_actions = ICommunityGameModeDispatcher { contract_address };

        (world, game_actions)
    }

    fn join_game(ref self: ContractState, game_id: u64) {
            // Obtain a mutable reference to the contract's default world state.
            let mut world = self.world_default();
            // Retrieve the address of the user who is calling this function. This is the player
            // joining the game.
            let caller = get_caller_address();

            // Read the `Game` model using the provided `game_id`.
            let mut game: Game = world.read_model(game_id);
            // Assert that the game's status is `Lobby`, meaning it's open for players to join.
            assert(game.status == GameStatus::Lobby, NOT_IN_LOBBY);

            // Attempt to read a `Player` model for the calling address within the specified game.
            // If a player model exists with a non-zero `last_answer_time`, it means the player has
            // already joined.
            let player: Player = world.read_model((game_id, caller));
            assert(player.last_answer_time == 0, ALREADY_IN_GAME);

            // Create a new `Player` model for the joining player and persist it to the world state.
            world
                .write_model(
                    @Player {
                        game_id,
                        player_address: caller,
                        score: 0,
                        streak: 0,
                        last_answer_time: get_block_timestamp(),
                    },
                );

            // Increment the player count in the `Game` model.
            game.player_count += 1;
            // Update the `Game` model in the world state with the new player count.
            world.write_model(@game);
            // Create a `PlayerBoard` entry to track the order of players.
            world
                .write_model(
                    @PlayerBoard { game_id, player_id: game.player_count, player: caller },
                );

            // Emit an event to signal that a player has joined the game.
            world
                .emit_event(
                    @PlayerJoined {
                        game_id, player_address: caller, timestamp: get_block_timestamp(),
                    },
                );
        }
        #[test]
            #[available_gas(3000000000)]
            fn test_join_game_success() {
                let (world, game_actions) = test_setup();
                let host_addr = owner();
                let player1_addr = player1();
                let player2_addr = player2();
                let initial_time = 1000_u64;
                testing::set_block_timestamp(initial_time);
        
                // Setup: Create trivia, add question, create game
                testing::set_contract_address(host_addr);
                let trivia_id = game_actions.create_trivia();
                game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME);
                let game_id = game_actions.create_game(trivia_id);
        
                // --- Player 1 Joins (Success) ---
                testing::set_contract_address(player1_addr);
                game_actions.join_game(game_id);
        
                // Verify Player 1 state
                let player1_model: Player = world.read_model((game_id, player1_addr));
                assert_eq!(player1_model.game_id, game_id);
                assert_eq!(player1_model.player_address, player1_addr);
                assert_eq!(player1_model.score, 0);
                assert_eq!(player1_model.streak, 0);
                assert_eq!(player1_model.last_answer_time, initial_time);
        
                // Verify Game state
                let mut game: Game = world.read_model(game_id);
                assert_eq!(game.player_count, 1);
        
                // Verify PlayerBoard
                let board_p1: PlayerBoard = world.read_model((game_id, 1_u32));
                assert_eq!(board_p1.player, player1_addr);
        
                // --- Player 2 Joins (Success) ---
                let join_time_p2 = initial_time + 10;
                testing::set_block_timestamp(join_time_p2);
                testing::set_contract_address(player2_addr);
                game_actions.join_game(game_id);
        
                // Verify Player 2 state
                let player2_model: Player = world.read_model((game_id, player2_addr));
                assert_eq!(player2_model.game_id, game_id);
                assert_eq!(player2_model.player_address, player2_addr);
                assert_eq!(player2_model.score, 0);
                assert_eq!(player2_model.streak, 0);
                assert_eq!(player2_model.last_answer_time, join_time_p2);
        
                // Verify Game state
                game = world.read_model((game_id,));
                assert_eq!(game.player_count, 2);
        
                // Verify PlayerBoard
                let board_p2: PlayerBoard = world.read_model((game_id, 2_u32));
                assert_eq!(board_p2.player, player2_addr);
            }
        
            #[test]
            #[available_gas(3000000000)]
            #[should_panic(expected: ('Already in game', 'ENTRYPOINT_FAILED'))]
            fn test_double_join_game_failure() {
                let (world, game_actions) = test_setup();
                let host_addr = owner();
                let player1_addr = player1();
                let initial_time = 1000_u64;
                testing::set_block_timestamp(initial_time);
        
                // Setup: Create trivia, add question, create game
                testing::set_contract_address(host_addr);
                let trivia_id = game_actions.create_trivia();
                game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME);
                let game_id = game_actions.create_game(trivia_id);
        
                // --- Player 1 Joins (Success) ---
                testing::set_contract_address(player1_addr);
                game_actions.join_game(game_id);
        
                // Verify Player 1 state
                let player1_model: Player = world.read_model((game_id, player1_addr));
                assert_eq!(player1_model.game_id, game_id);
                assert_eq!(player1_model.player_address, player1_addr);
                assert_eq!(player1_model.score, 0);
                assert_eq!(player1_model.streak, 0);
                assert_eq!(player1_model.last_answer_time, initial_time);
        
                // Verify Game state
                let mut game: Game = world.read_model(game_id);
                assert_eq!(game.player_count, 1);
        
                // Verify PlayerBoard
                let board_p1: PlayerBoard = world.read_model((game_id, 1_u32));
                assert_eq!(board_p1.player, player1_addr);
        
                // --- Player 1 Joins again (Panics) ---
                game_actions.join_game(game_id);
            }
        
            #[test]
            #[available_gas(3000000000)]
            #[should_panic(expected: ('Not in lobby', 'ENTRYPOINT_FAILED'))]
            fn test_join_game_not_in_lobby() {
                let (world, game_actions) = test_setup();
                let host_addr = owner();
                let player1_addr = player1();
                let player2_addr = player2();
                let initial_time = 1000_u64;
                testing::set_block_timestamp(initial_time);
        
                // Setup: Create trivia, add question, create game
                testing::set_contract_address(host_addr);
                let trivia_id = game_actions.create_trivia();
                game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME);
                let game_id = game_actions.create_game(trivia_id);
        
                // --- Player 1 Joins (Success) ---
                testing::set_contract_address(player1_addr);
                game_actions.join_game(game_id);
        
                // Verify Player 1 state
                let player1_model: Player = world.read_model((game_id, player1_addr));
                assert_eq!(player1_model.game_id, game_id);
                assert_eq!(player1_model.player_address, player1_addr);
                assert_eq!(player1_model.score, 0);
                assert_eq!(player1_model.streak, 0);
                assert_eq!(player1_model.last_answer_time, initial_time);
        
                // Verify Game state
                let mut game: Game = world.read_model(game_id);
                assert_eq!(game.player_count, 1);
        
                // Verify PlayerBoard
                let board_p1: PlayerBoard = world.read_model((game_id, 1_u32));
                assert_eq!(board_p1.player, player1_addr);
        
                // --- Player 2 Joins (Success) ---
                let join_time_p2 = initial_time + 10;
                testing::set_block_timestamp(join_time_p2);
                testing::set_contract_address(player2_addr);
                game_actions.join_game(game_id);
        
                // Verify Player 2 state
                let player2_model: Player = world.read_model((game_id, player2_addr));
                assert_eq!(player2_model.game_id, game_id);
                assert_eq!(player2_model.player_address, player2_addr);
                assert_eq!(player2_model.score, 0);
                assert_eq!(player2_model.streak, 0);
                assert_eq!(player2_model.last_answer_time, join_time_p2);
        
                // Verify Game state
                game = world.read_model((game_id,));
                assert_eq!(game.player_count, 2);
        
                // Verify PlayerBoard
                let board_p2: PlayerBoard = world.read_model((game_id, 2_u32));
                assert_eq!(board_p2.player, player2_addr);
        
                testing::set_contract_address(host_addr);
                game_actions.start_game(game_id);
        
                testing::set_contract_address(non_player());
                game_actions.join_game(game_id);
            }
}

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

    // Test game start transition for host
    #[test]
    #[available_gas(3000000000)]
    fn test_start_game_success() {
        let (world, game_actions) = test_setup();
        let host_addr = owner();
        let player1_addr = player1();
        let initial_time = 1000_u64;
        testing::set_block_timestamp(initial_time);

        // Setup: Create trivia, add questions, create game, players join
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME);
        game_actions.add_question(trivia_id, Q2_TEXT, Q2_OPTIONS, Q2_ANSWER, Q2_TIME);
        let game_id = game_actions.create_game(trivia_id);
        testing::set_contract_address(player1_addr);
        game_actions.join_game(game_id);

        // --- Start Game (Success) ---
        testing::set_contract_address(host_addr);
        game_actions.start_game(game_id);

        // Verify Game state
        let game: Game = world.read_model((game_id,));
        assert_eq!(game.status, GameStatus::InProgress);
        assert_eq!(game.current_question, 1);
        assert_eq!(game.timer_end, initial_time + Q1_TIME.into());
    }

    #[test]
    #[available_gas(3000000000)]
    #[should_panic(expected: ('Unauthorized', 'ENTRYPOINT_FAILED'))]
    fn test_unauthorized_start_game_failure() {
        let (_, game_actions) = test_setup();
        let host_addr = owner();
        let player1_addr = player1();
        let initial_time = 1000_u64;
        testing::set_block_timestamp(initial_time);

        // Setup: Create trivia, add questions, create game, players join
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME);
        game_actions.add_question(trivia_id, Q2_TEXT, Q2_OPTIONS, Q2_ANSWER, Q2_TIME);
        let game_id = game_actions.create_game(trivia_id);
        testing::set_contract_address(player1_addr);
        game_actions.join_game(game_id);

        // --- Start Game (Success) ---
        testing::set_contract_address(player1_addr);
        game_actions.start_game(game_id);
    }

    #[test]
    #[available_gas(3000000000)]
    #[should_panic(expected: ('Invalid game status', 'ENTRYPOINT_FAILED'))]
    fn test_start_game_invalid_status_fails() {
        let (_, game_actions) = test_setup();
        let host_addr = owner();
        let player1_addr = player1();
        let initial_time = 1000_u64;
        testing::set_block_timestamp(initial_time);

        // Setup: Create trivia, add questions, create game, players join
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME);
        game_actions.add_question(trivia_id, Q2_TEXT, Q2_OPTIONS, Q2_ANSWER, Q2_TIME);
        let game_id = game_actions.create_game(trivia_id);
        testing::set_contract_address(player1_addr);
        game_actions.join_game(game_id);

        // --- Start Game (Success) ---
        testing::set_contract_address(host_addr);
        game_actions.start_game(game_id);

        // --- Start Game again (Fails) ---
        game_actions.start_game(game_id);
    }

    #[test]
    #[available_gas(3000000000)]
    #[should_panic(expected: ('No questions', 'ENTRYPOINT_FAILED'))]
    fn test_start_game_no_question_fails() {
        let (_, game_actions) = test_setup();
        let host_addr = owner();
        let player1_addr = player1();
        let initial_time = 1000_u64;
        testing::set_block_timestamp(initial_time);

        // Setup: Create trivia, add questions, create game, players join
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        let game_id = game_actions.create_game(trivia_id);
        testing::set_contract_address(player1_addr);
        game_actions.join_game(game_id);

        // --- Start Game (Fails) ---
        testing::set_contract_address(host_addr);
        game_actions.start_game(game_id);
    }

    #[test]
    #[available_gas(3000000000)]
    #[should_panic(expected: ('No players', 'ENTRYPOINT_FAILED'))]
    fn test_start_game_no_player_fails() {
        let (_, game_actions) = test_setup();
        let host_addr = owner();

        let initial_time = 1000_u64;
        testing::set_block_timestamp(initial_time);

        // Setup: Create trivia, add questions, create game, players join
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME);
        game_actions.add_question(trivia_id, Q2_TEXT, Q2_OPTIONS, Q2_ANSWER, Q2_TIME);
        let game_id = game_actions.create_game(trivia_id);

        // --- Start Game (Success) ---
        testing::set_contract_address(host_addr);
        game_actions.start_game(game_id);
    }

    // Tests for `submit_answer`
    #[test]
    #[available_gas(3000000000)]
    fn test_submit_answer_success() {
        let (world, game_actions) = test_setup();
        let host_addr = owner();
        let player1_addr = player1();
        let player2_addr = player2();
        let start_time = 1000_u64;

        // Setup: trivia, 2 questions, game, 2 players, start game
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME); // Index 1
        game_actions.add_question(trivia_id, Q2_TEXT, Q2_OPTIONS, Q2_ANSWER, Q2_TIME); // Index 2
        let game_id = game_actions.create_game(trivia_id);

        testing::set_block_timestamp(start_time);
        testing::set_contract_address(player1_addr);
        game_actions.join_game(game_id);
        testing::set_contract_address(player2_addr);
        game_actions.join_game(game_id);

        testing::set_contract_address(host_addr);
        game_actions.start_game(game_id);

        let q1_timer_end = start_time + Q1_TIME.into();

        // --- Player 1 Submits Correct Answer (Success) ---
        let p1_submit_time = start_time + 5; // Submit 5s after start
        testing::set_block_timestamp(p1_submit_time);
        testing::set_contract_address(player1_addr);
        game_actions.submit_answer(game_id, Q1_ANSWER);

        // Verify Player 1 score
        let p1_model: Player = world.read_model((game_id, player1_addr));
        let time_remaining = q1_timer_end - p1_submit_time;
        let expected_bonus = time_remaining * 10;
        let expected_score: u32 = (100 + expected_bonus)
            .try_into()
            .unwrap(); // Base score + time bonus
        assert_eq!(p1_model.score, expected_score); // check score
        assert_eq!(p1_model.streak, 1); // Streak is 1

        // Verify Answer model
        let answer_key = (game_id, 1_u8, player1_addr); // Q1 index is 1
        let answer: Answer = world.read_model(answer_key);
        assert!(answer.is_correct);
        assert_eq!(answer.timestamp, p1_submit_time);

        // --- Player 2 Submits Incorrect Answer (Success) ---
        let p2_submit_time = start_time + 8;
        testing::set_block_timestamp(p2_submit_time);
        testing::set_contract_address(player2_addr);
        let incorrect_answer = (Q1_ANSWER + 1) % 3;
        game_actions.submit_answer(game_id, incorrect_answer);

        // Verify Player 2 score
        let p2_model: Player = world.read_model((game_id, player2_addr));
        assert_eq!(p2_model.score, 0); // Incorrect answer gets 0 points
        assert_eq!(p2_model.streak, 0); // Streak reset/remains 0
    }

    #[test]
    #[available_gas(3000000000)]
    #[should_panic(expected: ('Invalid game status', 'ENTRYPOINT_FAILED'))]
    fn test_submit_answer_invalid_game_status() {
        let (_, game_actions) = test_setup();
        let host_addr = owner();
        let player1_addr = player1();
        let player2_addr = player2();
        let start_time = 1000_u64;

        // Setup: trivia, 2 questions, game, 2 players, start game
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME); // Index 1
        let game_id = game_actions.create_game(trivia_id);

        testing::set_block_timestamp(start_time);
        testing::set_contract_address(player1_addr);
        game_actions.join_game(game_id);
        testing::set_contract_address(player2_addr);
        game_actions.join_game(game_id);

        testing::set_contract_address(host_addr);
        game_actions.start_game(game_id);

        // --- Player 1 Submits Correct Answer (Fails) ---
        let p1_submit_time = start_time + 5;
        testing::set_block_timestamp(p1_submit_time);
        testing::set_contract_address(player1_addr);
        game_actions.submit_answer(game_id, Q1_ANSWER);

        testing::set_contract_address(host_addr);
        game_actions.next_question(game_id);

        testing::set_contract_address(player1_addr);
        game_actions.submit_answer(game_id, Q1_ANSWER);
    }

    #[test]
    #[available_gas(3000000000)]
    #[should_panic(expected: ('Time expired', 'ENTRYPOINT_FAILED'))]
    fn test_submit_answer_after_time_elapsed_fails() {
        let (_, game_actions) = test_setup();
        let host_addr = owner();
        let player1_addr = player1();
        let player2_addr = player2();
        let start_time = 1000_u64;

        // Setup: trivia, 2 questions, game, 2 players, start game
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME); // Index 1
        game_actions.add_question(trivia_id, Q2_TEXT, Q2_OPTIONS, Q2_ANSWER, Q2_TIME); // Index 2
        let game_id = game_actions.create_game(trivia_id);

        testing::set_block_timestamp(start_time);
        testing::set_contract_address(player1_addr);
        game_actions.join_game(game_id);
        testing::set_contract_address(player2_addr);
        game_actions.join_game(game_id);

        testing::set_contract_address(host_addr);
        game_actions.start_game(game_id);

        let q1_timer_end = start_time + Q1_TIME.into();

        // --- Player 1 Submits Correct Answer (Success) ---
        let p1_submit_time = q1_timer_end + 5; // Submit 5s after start
        testing::set_block_timestamp(p1_submit_time);
        testing::set_contract_address(player1_addr);
        game_actions.submit_answer(game_id, Q1_ANSWER);
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

    #[test]
    #[available_gas(3000000000)]
    fn test_add_question_success() {
        let (world, game_actions) = test_setup();
        let host_addr = owner();
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();

        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME);

        // Verify Question model (Assuming 1-based indexing is fixed)
        let question_index = 1_u8;
        let question: Question = world.read_model((trivia_id, question_index));

        assert_eq!(question.trivia_id, trivia_id);
        assert_eq!(question.question_index, question_index);
        assert_eq!(question.text, Q1_TEXT);
        assert_eq!(question.options, Q1_OPTIONS);
        assert_eq!(question.correct_answer, Q1_ANSWER);
        assert_eq!(question.time_limit, Q1_TIME);

        // Verify TriviaInfo update
        let trivia_info: TriviaInfo = world.read_model(trivia_id);
        assert_eq!(trivia_info.question_count, 1);
    }

    #[test]
    #[available_gas(3000000000)]
    #[should_panic(expected: ('Unauthorized', 'ENTRYPOINT_FAILED'))]
    fn test_add_question_unauthorized() {
        let (_, game_actions) = test_setup();
        let host_addr = owner();
        let other_addr = non_owner();

        // Create trivia as owner
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();

        // Try to add question as non-owner
        testing::set_contract_address(other_addr);
        game_actions
            .add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME); // Should panic
    }

    // Test `next_question`
    #[test]
    #[available_gas(3000000000)]
    fn test_next_question_success() {
        let (world, game_actions) = test_setup();
        let host_addr = owner();
        let player1_addr = player1();
        let start_time = 1000_u64;

        // Setup: trivia, 2 questions, game, 1 player, start game
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME); // Q1
        game_actions.add_question(trivia_id, Q2_TEXT, Q2_OPTIONS, Q2_ANSWER, Q2_TIME); // Q2
        let game_id = game_actions.create_game(trivia_id);
        testing::set_contract_address(player1_addr);
        game_actions.join_game(game_id);
        testing::set_block_timestamp(start_time);
        testing::set_contract_address(host_addr);
        game_actions.start_game(game_id);

        // --- Advance by Host Before Timer (Success) ---
        let host_advance_time = start_time + 10;
        testing::set_block_timestamp(host_advance_time);
        testing::set_contract_address(host_addr);
        game_actions.next_question(game_id);

        // Verify game state advanced to Q2
        let game: Game = world.read_model((game_id,));
        assert_eq!(game.current_question, 2);
        assert_eq!(game.status, GameStatus::InProgress);
        let expected_q2_timer_end = host_advance_time + Q2_TIME.into();
        assert_eq!(game.timer_end, expected_q2_timer_end);

        // --- Advance by Timer (Success) ---
        // Need to submit an answer first to reset player state for Q2 if needed,
        // but advancing doesn't strictly require it.
        let timer_advance_time = expected_q2_timer_end + 1;
        testing::set_block_timestamp(timer_advance_time);
        // Call next_question as anyone (e.g., player1) - timer condition should allow it
        testing::set_contract_address(player1_addr);
        game_actions.next_question(game_id);

        // Verify game ended (since only 2 questions)
        let game: Game = world.read_model((game_id,));
        assert_eq!(game.status, GameStatus::Ended);
        assert_eq!(game.timer_end, 0);
    }

    #[should_panic(expected: ('Invalid game status', 'ENTRYPOINT_FAILED'))]
    fn test_next_question_invalid_status() {
        let (world, game_actions) = test_setup();
        let host_addr = owner();
        let player1_addr = player1();
        let start_time = 1000_u64;

        // Setup: trivia, 2 questions, game, 1 player, start game
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME); // Q1
        game_actions.add_question(trivia_id, Q2_TEXT, Q2_OPTIONS, Q2_ANSWER, Q2_TIME); // Q2
        let game_id = game_actions.create_game(trivia_id);
        testing::set_contract_address(player1_addr);
        game_actions.join_game(game_id);
        testing::set_block_timestamp(start_time);
        testing::set_contract_address(host_addr);
        game_actions.start_game(game_id);

        // --- Advance by Host Before Timer (Success) ---
        let host_advance_time = start_time + 10;
        testing::set_block_timestamp(host_advance_time);
        testing::set_contract_address(host_addr);
        game_actions.next_question(game_id);

        // Verify game state advanced to Q2
        let game: Game = world.read_model((game_id,));
        assert_eq!(game.current_question, 2);
        assert_eq!(game.status, GameStatus::InProgress);
        let expected_q2_timer_end = host_advance_time + Q2_TIME.into();
        assert_eq!(game.timer_end, expected_q2_timer_end);

        // --- Advance by Timer (Success) ---
        // Need to submit an answer first to reset player state for Q2 if needed,
        // but advancing doesn't strictly require it.
        let timer_advance_time = expected_q2_timer_end + 1;
        testing::set_block_timestamp(timer_advance_time);
        // Call next_question as anyone (e.g., player1) - timer condition should allow it
        testing::set_contract_address(player1_addr);
        game_actions.next_question(game_id);

        // Verify game ended (since only 2 questions)
        let game: Game = world.read_model((game_id,));
        assert_eq!(game.status, GameStatus::Ended);
        assert_eq!(game.timer_end, 0);

        testing::set_contract_address(host_addr);
        game_actions.next_question(game_id);
    }

    #[test]
    #[available_gas(3000000000)]
    #[should_panic(expected: ('Unauthorized', 'ENTRYPOINT_FAILED'))]
    fn test_next_question_unauthorized() {
        let (world, game_actions) = test_setup();
        let host_addr = owner();
        let player1_addr = player1();
        let start_time = 1000_u64;

        // Setup: trivia, 2 questions, game, 1 player, start game
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME); // Q1
        game_actions.add_question(trivia_id, Q2_TEXT, Q2_OPTIONS, Q2_ANSWER, Q2_TIME); // Q2
        let game_id = game_actions.create_game(trivia_id);
        testing::set_contract_address(player1_addr);
        game_actions.join_game(game_id);
        testing::set_block_timestamp(start_time);
        testing::set_contract_address(host_addr);
        game_actions.start_game(game_id);

        // --- Advance by Player Before Timer (Fails) ---
        let host_advance_time = start_time + 10;
        testing::set_block_timestamp(host_advance_time);
        testing::set_contract_address(player1_addr);
        game_actions.next_question(game_id);
    }

    #[test]
    #[available_gas(3000000000)]
    fn test_create_trivia_success() {
        let (world, game_actions) = test_setup();
        let host_addr = owner();
        testing::set_contract_address(host_addr);

        let trivia_id = game_actions.create_trivia();
        assert_eq!(trivia_id, 1);

        // Verify Trivia model
        let trivia: Trivia = world.read_model(trivia_id);
        assert_eq!(trivia.trivia_id, trivia_id);
        assert_eq!(trivia.owner, host_addr);

        // Verify TriviaInfo model
        let trivia_info: TriviaInfo = world.read_model(trivia_id);
        assert_eq!(trivia_info.trivia_id, trivia_id);
        assert_eq!(trivia_info.question_count, 0);
    }

    // Test View Leaderboard
    #[test]
    #[available_gas(3000000000)]
    fn test_view_leader_board() {
        let (world, game_actions) = test_setup();
        let host_addr = owner();
        let player1_addr = player1();
        let player2_addr = player2();
        let start_time = 1000_u64;

        // Setup: trivia, Q1, game, 2 players, start, p1 answers correctly, p2 incorrectly
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME);
        let game_id = game_actions.create_game(trivia_id);

        testing::set_block_timestamp(start_time);
        testing::set_contract_address(player1_addr);
        game_actions.join_game(game_id);
        testing::set_contract_address(player2_addr);
        game_actions.join_game(game_id);

        testing::set_contract_address(host_addr);
        game_actions.start_game(game_id);
        let q1_timer_end = start_time + Q1_TIME.into();

        // Player 1 answers correctly (quickly)
        let p1_submit_time = start_time + 2;
        testing::set_block_timestamp(p1_submit_time);
        testing::set_contract_address(player1_addr);
        game_actions.submit_answer(game_id, Q1_ANSWER);
        let p1_time_bonus = (q1_timer_end - p1_submit_time) * 10;
        let p1_expected_score: u32 = (100 + p1_time_bonus).try_into().unwrap();

        // Player 2 answers incorrectly
        let p2_submit_time = start_time + 5;
        testing::set_block_timestamp(p2_submit_time);
        testing::set_contract_address(player2_addr);
        let incorrect_answer = (Q1_ANSWER + 1) % 3;
        game_actions.submit_answer(game_id, incorrect_answer);
        let p2_expected_score: u32 = 0;

        // --- View Leaderboard ---
        let p1_model: Player = world.read_model((game_id, player1_addr));
        let p2_model: Player = world.read_model((game_id, player2_addr));

        assert_eq!(p1_model.score, p1_expected_score);
        assert_eq!(p2_model.score, p2_expected_score);

        // The `view_leader_board` function iterates based on PlayerBoard.
        let board_p1: PlayerBoard = world.read_model((game_id, 1_u32));
        let board_p2: PlayerBoard = world.read_model((game_id, 2_u32));
        assert_eq!(board_p1.player, player1_addr);
        assert_eq!(board_p2.player, player2_addr);

        // expected
        let leaderboard = game_actions.view_leader_board(game_id);
        assert_eq!(leaderboard.len(), 2);
        assert_eq!(*leaderboard.at(0), (player1_addr, p1_expected_score));
        assert_eq!(*leaderboard.at(1), (player2_addr, p2_expected_score));
    }
}

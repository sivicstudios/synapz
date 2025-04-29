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
}

#[cfg(test)]
mod tests {
    use core::starknet::ContractAddress;
    use starknet::{testing, contract_address_const};
    use dojo_cairo_test::WorldStorageTestTrait;
    use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
    use dojo::world::{WorldStorageTrait, WorldStorage};
    use dojo::world::{world, IWorldDispatcherTrait};
    use dojo::event::Event;
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef,
    };

    use synapz::systems::actions::actions;
    use synapz::interfaces::community::{
        ICommunityGameModeDispatcher, ICommunityGameModeDispatcherTrait,
    };
    use synapz::models::{
        community::{
            Game, m_Game, Trivia, m_Trivia, TriviaInfo, m_TriviaInfo, Question, m_Question, Answer,
            m_Answer, GameStatus, Player, m_Player, PlayerBoard, m_PlayerBoard,
        },
        shared::ResourceCounter,
    };
    use synapz::events::community::{
        TriviaCreated, e_TriviaCreated, GameCreated, e_GameCreated, QuestionAdded, e_QuestionAdded,
        PlayerJoined, e_PlayerJoined, GameStarted, e_GameStarted, AnswerSubmitted,
        e_AnswerSubmitted, NextQuestion, e_NextQuestion, GameEnded, e_GameEnded,
    };

    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "synapz",
            resources: [
                TestResource::Contract(actions::TEST_CLASS_HASH),
                TestResource::Model(m_Game::TEST_CLASS_HASH),
                TestResource::Model(m_Trivia::TEST_CLASS_HASH),
                TestResource::Model(m_TriviaInfo::TEST_CLASS_HASH),
                TestResource::Model(m_Question::TEST_CLASS_HASH),
                TestResource::Model(m_Answer::TEST_CLASS_HASH),
                TestResource::Model(m_Player::TEST_CLASS_HASH),
                TestResource::Model(m_PlayerBoard::TEST_CLASS_HASH),
                TestResource::Event(e_TriviaCreated::TEST_CLASS_HASH),
                TestResource::Event(e_PlayerJoined::TEST_CLASS_HASH),
                TestResource::Event(e_GameStarted::TEST_CLASS_HASH),
                TestResource::Event(e_AnswerSubmitted::TEST_CLASS_HASH),
                TestResource::Event(e_NextQuestion::TEST_CLASS_HASH),
                TestResource::Event(e_GameEnded::TEST_CLASS_HASH),
            ]
                .span(),
        };

        ndef
    }

    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"synapz", @"actions")
                .with_writer_of([dojo::utils::bytearray_hash(@"synapz")].span())
        ]
            .span()
    }

    #[test]
    fn test_world_test_set() {
        // Initialize test environment
        let caller = starknet::contract_address_const::<0x0>();
        let ndef = namespace_def();

        // Register the resources.
        let mut world = spawn_test_world([ndef].span());

        // Ensures permissions and initializations are synced.
        world.sync_perms_and_inits(contract_defs());

        let mut trivia: Trivia = world.read_model(1);
        assert(trivia.owner == caller, 'owner wrong 1');

        trivia.owner = contract_address_const::<0x1>();
        world.write_model_test(@trivia);

        let mut trivia: Trivia = world.read_model(1);
        assert(trivia.owner == contract_address_const::<0x1>(), 'owner wrong 2');

        world.erase_model(@trivia);
        let mut trivia: Trivia = world.read_model(1);
        assert(trivia.owner == contract_address_const::<0x0>(), 'owner wrong 1');
    }
}

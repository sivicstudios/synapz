#[test]
    #[available_gas(3000000000)]
    fn test_create_game_success() {
        let (world, game_actions) = test_setup();
        let host_addr = owner();
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME);

        let game_id = game_actions.create_game(trivia_id);
        assert_eq!(game_id, 1);

        // Verify Game model
        let game: Game = world.read_model(game_id);

        assert_eq!(game.game_id, game_id);
        assert_eq!(game.host, host_addr);
        assert_eq!(game.status, GameStatus::Lobby);
        assert_eq!(game.current_question, 0);
        assert_eq!(game.timer_end, 0);
        assert_eq!(game.trivia_id, trivia_id);
        assert_eq!(game.player_count, 0);
    }

    #[test]
    #[available_gas(3000000000)]
    #[should_panic(expected: ('Unauthorized', 'ENTRYPOINT_FAILED'))]
    fn test_create_game_unauthorized() {
        let (_, game_actions) = test_setup();
        let host_addr = owner();
        let other_addr = non_owner();

        // Create trivia as owner
        testing::set_contract_address(host_addr);
        let trivia_id = game_actions.create_trivia();
        game_actions.add_question(trivia_id, Q1_TEXT, Q1_OPTIONS, Q1_ANSWER, Q1_TIME);

        // Try to create game as non-owner
        testing::set_contract_address(other_addr);
        game_actions.create_game(trivia_id);
    }

fn create_game(ref self: ContractState, trivia_id: u64) -> u64 {
            // Obtain a mutable reference to the contract's default world state.
            let mut world = self.world_default();
            // Retrieve the address of the user who is calling this function. This user will be the
            // host of the new game.
            let caller = get_caller_address();

            // Generate a unique identifier for this new game session. This uses a contract-level
            // resource counter to ensure that each game has a distinct ID.
            let game_id = self.resource_uid('game_id');

            // Retrieve the trivia data model using the provided trivia ID.
            let trivia: Trivia = world.read_model(trivia_id);
            // Assert that the caller is the owner of the trivia.
            assert(trivia.owner == caller, UNAUTHORIZED);

            // Create the `Game` data model and persist it to the world state with its initial
            // configuration.
            world
                .write_model(
                    @Game {
                        game_id,
                        host: caller,
                        status: GameStatus::Lobby,
                        current_question: 0,
                        timer_end: 0,
                        trivia_id,
                        player_count: 0,
                    },
                );

            // Emit an event to signal that a new game session has been successfully created.
            // This event includes important details about the new game.
            world
                .emit_event(
                    @GameCreated { game_id, host: caller, timestamp: get_block_timestamp() },
                );

            // Return the unique identifier of the newly created game session.
            game_id
        }

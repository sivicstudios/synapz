#[dojo::contract]
pub mod actions {
    use dojo::event::EventStorage;
    use dojo::model::{ModelStorage};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use synapz::interfaces::community::ICommunityGameMode;
    use synapz::models::{
        community::{GameStatus, Trivia, TriviaInfo, Question, Game, Player, Answer, PlayerBoard},
        shared::ResourceCounter,
    };
    use synapz::events::community::{
        GameCreated, GameStarted, GameEnded, NextQuestion, QuestionAdded, AnswerSubmitted,
        PlayerJoined, TriviaCreated,
    };
    use synapz::errors::shared::{
        NOT_IN_GAME, ALREADY_ANSWERED, ALREADY_IN_GAME, NO_QUESTIONS, INVALID_GAME_STATUS,
        NOT_IN_LOBBY, TIME_EXPIRED, UNAUTHORIZED, NO_PLAYERS,
    };

    #[abi(embed_v0)]
    impl CommunityActionsImpl of ICommunityGameMode<ContractState> {
        /// Creates a new trivia game instance.
        ///
        /// This function initializes a new trivia game by:
        /// - Accessing the contract's default world state.
        /// - Determining the address of the user initiating the creation.
        /// - Generating a unique identifier for the new trivia game using a dedicated counter.
        /// - Persisting two core data models:
        ///   - `Trivia`: Stores essential information about the trivia game, including its unique
        ///   ID and the address of the creator (owner).
        ///   - `TriviaInfo`: Holds supplementary details about the trivia game, such as the initial
        ///   question count (set to 0).
        /// - Emitting a `TriviaCreated` event to log the creation of the new trivia game, including
        /// its ID, the host (creator), and the timestamp of creation.
        ///
        /// # Returns
        ///
        /// The unique identifier (`u64`) assigned to the newly created trivia game. This ID can be
        /// used to reference and interact with this specific trivia instance in subsequent
        /// operations.
        fn create_trivia(
            ref self: ContractState,
        ) -> u64 { // Obtain a mutable reference to the contract's default world state.
            // Retrieve the address of the user who is calling this function. This address will be
            // the owner of the new trivia game.

            // Generate a unique identifier for this new trivia game. This uses a contract-level
            // resource counter to ensure that each trivia game has a distinct ID.

            // Create the core `Trivia` data model and persist it to the world state.
            // This model stores fundamental information about the trivia game.

            // Create the `TriviaInfo` data model and persist it.
            // This model holds additional information, such as the number of questions currently
            // associated with the trivia (initially 0).

            // Emit an event to signal that a new trivia game has been successfully created.
            // This event includes important details about the new game.

            // Return the unique identifier of the newly created trivia game.
            0
        }

        /// Adds a new question to an existing trivia game.
        ///
        /// This function allows the owner of a trivia game to add a new question. It performs the
        /// following steps:
        /// - Retrieves the current world state.
        /// - Identifies the caller of the function to verify ownership.
        /// - Reads the `Trivia` model associated with the provided `trivia_id` to ensure the trivia
        ///   game exists.
        /// - Verifies that the caller is the owner of the specified trivia game; otherwise, the
        ///   transaction will be reverted.
        /// - Reads the associated `TriviaInfo` model to get the current question count.
        /// - Calculates the index for the new question.
        /// - Creates a new `Question` model containing the question details (text, options, correct
        ///   answer, and time limit) and persists it to the world state.
        /// - Increments the `question_count` in the `TriviaInfo` model and updates it in the world
        ///   state.
        /// - Emits a `QuestionAdded` event to log the addition of the new question, including the
        ///   trivia ID and the index of the added question.
        ///
        /// # Arguments
        ///
        /// * `trivia_id`: The unique identifier (`u64`) of the trivia game to which the question is
        ///   being added.
        /// * `text`: The text content (`felt252`) of the question.
        /// * `options`: A string (`felt252`) containing the possible answer options for the
        ///    question.
        /// * `correct_answer`: An unsigned 8-bit integer (`u8`) representing the index of the
        ///   correct answer within the `options`.
        /// * `time_limit`: An unsigned 8-bit integer (`u8`) specifying the time limit in seconds
        ///   for answering this question.
        ///
        /// # Panics
        ///
        /// This function will panic with the `UNAUTHORIZED` error if the caller is not the owner of
        /// the trivia game specified by `trivia_id`.
        fn add_question(
            ref self: ContractState,
            trivia_id: u64,
            text: felt252,
            options: felt252,
            correct_answer: u8,
            time_limit: u8,
        ) { 
        // Obtain a mutable reference to the contract's default world state.
            let mut world = self.world_default();
            // Retrieve the address of the user who is calling this function.
            let caller = get_caller_address();

            // Read the `Trivia` model using the provided `trivia_id`. This ensures the trivia game
            // exists.
            let trivia: Trivia = world.read_model(trivia_id);
            // Assert that the caller is the owner of the trivia game. If not, the transaction will
            // fail.
            assert(trivia.owner == caller, UNAUTHORIZED);

            // Read the `TriviaInfo` model associated with the `trivia_id` to access the current
            // question count.
            let mut trivia_info: TriviaInfo = world.read_model(trivia_id);
            // Calculate the index for the new question. It will be one greater than the current
            // question count.
            let question_index = trivia_info.question_count + 1;

            // Create a new `Question` model with the provided details and persist it to the world
            // state.
            world
                .write_model(
                    @Question {
                        trivia_id, question_index, text, options, correct_answer, time_limit,
                    },
                );

            // Increment the question count in the `TriviaInfo` model.
            trivia_info.question_count += 1;
            // Update the `TriviaInfo` model in the world state with the new question count.
            world.write_model(@trivia_info);

            // Emit an event to signal that a new question has been added to the trivia game.
            world.emit_event(@QuestionAdded { trivia_id, question_index });
        }

        /// Creates a new instance of a trivia game for players to join.
        ///
        /// This function initializes a new game session based on an existing trivia content set. It
        /// performs the following actions:
        /// - Accesses the contract's default world state.
        /// - Identifies the user initiating the game creation, who becomes the host.
        /// - Asserts that the host is the trivia owner.
        /// - Generates a unique identifier for this new game session using a dedicated counter.
        /// - Creates and persists a `Game` model containing the initial state of the game:
        ///   - `game_id`: The unique identifier for this game session.
        ///   - `host`: The address of the user who created the game.
        ///   - `status`: Set to `GameStatus::Lobby`, indicating that the game is open for players
        ///     to join.
        ///   - `current_question`: Initialized to 0, as no questions have been presented yet.
        ///   - `timer_end`: Set to 0 initially, as no timer is active in the lobby state.
        ///   - `trivia_id`: The identifier of the specific trivia content (questions, etc.) that
        ///     this game will use.
        ///   - `player_count`: Initialized to 0, as no players have joined yet.
        /// - Emits a `GameCreated` event to log the creation of the new game session, including its
        ///   ID, the host, and the timestamp of creation.
        ///
        /// # Arguments
        ///
        /// * `trivia_id`: The unique identifier (`u64`) of the trivia content that this game
        ///   session will use. This ID must correspond to an existing trivia created using the
        /// * `create_trivia` function.
        ///
        /// # Returns
        ///
        /// The unique identifier (`u64`) assigned to the newly created game session. This ID is
        /// used for players to join and interact with this specific game.
        fn create_game(
            ref self: ContractState, trivia_id: u64,
        ) -> u64 { // Obtain a mutable reference to the contract's default world state.
            // Retrieve the address of the user who is calling this function. This user will be the
            // host of the new game.

            // Generate a unique identifier for this new game session. This uses a contract-level
            // resource counter to ensure that each game has a distinct ID.

            // Retrieve the trivia data model using the provided trivia ID.

            // Assert that the caller is the owner of the trivia.

            // Create the `Game` data model and persist it to the world state with its initial
            // configuration.

            // Emit an event to signal that a new game session has been successfully created.
            // This event includes important details about the new game.

            // Return the unique identifier of the newly created game session.
            0
        }

        /// Allows a user to join an existing trivia game that is in the lobby state.
        ///
        /// This function enables a player to join a specific game session identified by `game_id`.
        /// It performs the following steps:
        /// - Retrieves the current world state.
        /// - Identifies the caller of the function, who will be the player joining the game.
        /// - Reads the `Game` model associated with the provided `game_id` to ensure the game
        ///   exists and to check its current status.
        /// - Asserts that the game's status is `GameStatus::Lobby`. Players cannot join games that
        ///   have already started or finished.
        /// - Attempts to read a `Player` model associated with the given `game_id` and the caller's
        ///   address.
        /// - Asserts that no existing `Player` model is found for the caller in this game
        ///   (indicated by `last_answer_time` being 0). This prevents a player from joining the
        ///   same game multiple times.
        /// - Creates a new `Player` model with the initial state for the joining player:
        ///   - `game_id`: The ID of the game being joined.
        ///   - `player_address`: The address of the player joining.
        ///   - `score`: Initialized to 0.
        ///   - `streak`: Initialized to 0 (representing the current consecutive correct answers).
        ///   - `last_answer_time`: Set to the current block timestamp, indicating the time the
        ///     player joined.
        /// - Persists the new `Player` model to the world state.
        /// - Increments the `player_count` in the `Game` model and updates it in the world state.
        /// - Creates a `PlayerBoard` model to track the order of players joining the game. The
        ///   `player_id` is set to the current `player_count` of the game.
        /// - Persists the `PlayerBoard` model to the world state.
        /// - Emits a `PlayerJoined` event to log the player joining the game, including the game
        ///   ID, the player's address, and the timestamp of joining.
        ///
        /// # Arguments
        ///
        /// * `game_id`: The unique identifier (`u64`) of the game session the player wants to join.
        ///
        /// # Panics
        ///
        /// This function will panic with the following errors:
        /// - `NOT_IN_LOBBY`: If the game specified by `game_id` is not in the `Lobby` state (e.g.,
        ///   it has already started).
        /// - `ALREADY_IN_GAME`: If the calling player's address is already associated with a
        ///   `Player` model in the specified `game_id`.
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

        /// Starts a trivia game session.
        ///
        /// This function allows the host of a game to initiate the game play. It performs the
        /// following actions:
        /// - Retrieves the current world state.
        /// - Identifies the caller of the function to verify if they are the host.
        /// - Reads the `Game` model associated with the provided `game_id`.
        /// - Asserts that the caller is the host of the game; otherwise, the transaction is
        /// aborted.
        /// - Asserts that the game's status is currently `GameStatus::Lobby`, as only games in the
        ///   lobby can be started.
        /// - Reads the `TriviaInfo` model associated with the game's `trivia_id` to ensure there
        ///   are questions available.
        /// - Asserts that the trivia has at least one question; a game cannot start without
        ///   questions.
        /// - Reads the first question (with `question_index` 0) from the trivia.
        /// - Updates the `Game` model:
        ///   - Sets the `status` to `GameStatus::InProgress`.
        ///   - Sets the `timer_end` to the current block timestamp plus the time limit of the first
        ///     question. This starts the timer for the first question.
        /// - Persists the updated `Game` model to the world state.
        /// - Emits a `GameStarted` event to log the start of the game, including the `game_id` and
        ///   the timestamp.
        ///
        /// # Arguments
        ///
        /// * `game_id`: The unique identifier (`u64`) of the game session to start.
        ///
        /// # Panics
        ///
        /// This function will panic with the following errors:
        /// - `UNAUTHORIZED`: If the caller is not the host of the game specified by `game_id`.
        /// - `INVALID_GAME_STATUS`: If the game specified by `game_id` is not in the `Lobby` state.
        /// - `NO_QUESTIONS`: If the trivia associated with the game has no questions added to it.

        fn start_game(ref self: ContractState, game_id: u64) {
            // Obtain a mutable reference to the contract's default world state.
            let mut world = self.world_default();
            // Retrieve the address of the user who is calling this function.
            let caller = get_caller_address();

            // Read the `Game` model using the provided `game_id`.
            let mut game: Game = world.read_model(game_id);

            // Assert that the caller is the host of the game.
            assert(game.host == caller, UNAUTHORIZED);

            // Assert that the game is currently in the `Lobby` state.
            assert(game.status == GameStatus::Lobby, INVALID_GAME_STATUS);

            // Assert that at least one player has joined
            assert(game.player_count > 0, NO_PLAYERS);

            // Read the `TriviaInfo` model associated with the game's trivia content.
            let trivia_info: TriviaInfo = world.read_model(game.trivia_id);

            // Assert that there is at least one question in the trivia.
            assert(trivia_info.question_count > 0, NO_QUESTIONS);

            // Read the first question of the trivia (question_index 0).
            let question: Question = world.read_model((game.trivia_id, 1_u8));

            // Update the game status to `InProgress`.
            game.status = GameStatus::InProgress;

            // Set the timer end for the first question based on its time limit.
            game.current_question = question.question_index;
            game.timer_end = get_block_timestamp() + question.time_limit.into();

            // Update the `Game` model in the world state.
            world.write_model(@game);

            // Emit an event to signal that the game has started.
            world.emit_event(@GameStarted { game_id, timestamp: get_block_timestamp() });
        }

        /// Allows a player to submit an answer to the current question in a running game.
        ///
        /// This function processes a player's submitted answer for the current question in a trivia
        /// game. It performs the following steps:
        /// - Retrieves the current world state.
        /// - Identifies the caller of the function, who is the player submitting the answer.
        /// - Gets the current block timestamp.
        /// - Reads the `Game` model associated with the provided `game_id`.
        /// - Asserts that the game's status is `GameStatus::InProgress`; answers cannot be
        ///   submitted if the game hasn't started or has finished.
        /// - Asserts that the current block timestamp is not after the `timer_end` of the current
        ///   question, ensuring the submission is within the time limit.
        /// - Reads the `Player` model associated with the given `game_id` and the caller's address
        ///   to verify the player is part of the game.
        /// - Asserts that the `player.last_answer_time` is not `0`, confirming the
        ///   player is in the correct game.
        /// - Constructs a unique key for the player's answer to the current question.
        /// - Attempts to read an existing `Answer` model using this key.
        /// - Asserts that no answer has already been submitted by this player for the current
        ///   question (indicated by `existing.timestamp` being 0). This prevents duplicate
        ///   submissions.
        /// - Reads the current `Question` model based on the game's `trivia_id` and
        ///   `current_question` index.
        /// - Determines if the submitted `answer_index` matches the `correct_answer` of the
        ///   current question.
        /// - Calculates a `time_bonus` based on the remaining time when the answer was submitted.
        ///   Earlier submissions get a higher bonus.
        /// - Calculates the score awarded for the current question: 100 points for a correct answer
        ///   plus the `time_bonus`, or 0 for an incorrect answer.
        /// - Updates the player's `score`.
        /// - Updates the player's `streak`: increments it if the answer is correct, resets it to 0
        ///   if incorrect.
        /// - Awards bonus points based on the current `streak` (50 points per consecutive correct
        ///   answer).
        /// - Persists the updated `Player` model to the world state.
        /// - Creates a new `Answer` model to record the player's submission details:
        ///   - `game_id`: The ID of the game.
        ///   - `question_index`: The index of the question answered.
        ///   - `player_address`: The address of the player who submitted the answer.
        ///   - `answer_index`: The index of the answer submitted by the player.
        ///   - `is_correct`: A boolean indicating if the answer was correct.
        ///   - `timestamp`: The time the answer was submitted.
        /// - Persists the new `Answer` model to the world state.
        /// - Emits an `AnswerSubmitted` event, including the submitted answer index, the game ID,
        ///   the player's address, and the score awarded for this answer.
        ///
        /// # Arguments
        ///
        /// * `game_id`: The unique identifier (`u64`) of the game session.
        /// * `answer_index`: An unsigned 8-bit integer (`u8`) representing the index of the answer
        /// submitted by the player. This index should correspond to one of the options in the
        /// current question's `options` field.
        ///
        /// # Panics
        ///
        /// This function will panic with the following errors:
        /// - `INVALID_GAME_STATUS`: If the game specified by `game_id` is not in the `InProgress`
        ///   state.
        /// - `TIME_EXPIRED`: If the current block timestamp is after the timer for the current
        ///   question has ended.
        /// - `NOT_IN_GAME`: If the calling player is not registered as a player in the specified
        ///   `game_id`.
        /// - `ALREADY_ANSWERED`: If the calling player has already submitted an answer for the
        ///   current question.
        fn submit_answer(ref self: ContractState, game_id: u64, answer_index: u8) {
            // Obtain a mutable reference to the contract's default world state.
            let mut world = self.world_default();
            // Retrieve the address of the user who is calling this function.
            let caller = get_caller_address();
            // Get the current block timestamp.
            let now = get_block_timestamp();

            // Read the `Game` model using the provided `game_id`.
            let game: Game = world.read_model(game_id);
            // Assert that the game is currently in the `InProgress` state.
            assert(game.status == GameStatus::InProgress, INVALID_GAME_STATUS);
            // Assert that the current time is within the time limit for the current question.
            assert(now <= game.timer_end, TIME_EXPIRED);

            // Read the `Player` model for the calling player in the specified game.
            let mut player: Player = world.read_model((game_id, caller));
            // Assert that the player is indeed part of this game.
            assert(player.last_answer_time != 0, NOT_IN_GAME);

            // Construct the key to check if the player has already answered this question.
            let answer_key = (game_id, game.current_question, caller);
            // Attempt to read an existing `Answer` model for this question and player.
            let existing: Answer = world.read_model(answer_key);
            // Assert that no answer has been submitted yet by this player for the current question.
            assert(existing.timestamp == 0, ALREADY_ANSWERED);

            // Read the current `Question` model based on the game's trivia ID and the current
            // question index.
            let question: Question = world.read_model((game.trivia_id, game.current_question));
            // Determine if the submitted answer is correct.
            let correct = answer_index == question.correct_answer;
            // Calculate the time bonus based on the remaining time (in seconds) multiplied by 10.
            let time_bonus = (game.timer_end - now) * 10;

            // Store the player's previous score for the event.
            let prev_score = player.score;
            // Award points based on whether the answer is correct, including the time bonus.
            player.score += if correct {
                (100 + time_bonus).try_into().unwrap()
            } else {
                0
            };

            // Update the player's streak based on the correctness of the answer.
            if correct {
                player.streak += 1;
                if player.streak > 1 {
                    // Award bonus points based on the current streak.
                    player.score += (player.streak).into() * 50;
                }
            } else {
                player.streak = 0;
            }
            // Store the player's score after updating.
            let post_score = player.score;
            // Update the `Player` model in the world state.
            world.write_model(@player);

            // Create a new `Answer` model to record the submitted answer.
            world
                .write_model(
                    @Answer {
                        game_id,
                        question_index: game.current_question,
                        player_address: caller,
                        answer_index,
                        is_correct: correct,
                        timestamp: now,
                    },
                );

            // Emit an event to signal that a player has submitted an answer.
            world
                .emit_event(
                    @AnswerSubmitted {
                        answer_index: answer_index.into(),
                        game_id,
                        player_address: caller,
                        score_awarded: post_score - prev_score,
                    },
                );
        }

        /// Advances the trivia game to the next question or ends the game if all questions have
        /// been presented.
        ///
        /// This function handles the progression of a trivia game to the subsequent question. It
        /// can be triggered by the game host or automatically after the timer for the current
        /// question expires. The function performs the following steps:
        /// - Retrieves the current world state.
        /// - Identifies the caller of the function.
        /// - Reads the `Game` model associated with the provided `game_id`.
        /// - Asserts that the game's status is `GameStatus::InProgress`; the game must be running
        ///   to advance to the next question.
        /// - Asserts that either the caller is the game host or the current block timestamp is
        ///   after the `timer_end` of the current question. This allows the host to manually
        ///   advance, or the game to proceed automatically after the time limit.
        /// - Reads the `TriviaInfo` model associated with the game's `trivia_id` to get the total
        ///   number of questions.
        /// - Checks if the index of the next question (`game.current_question + 1`) exceeds or
        ///   equals the total number of questions in the trivia:
        ///   - If it does, the game is considered finished. The game's `status` is updated to
        ///     `GameStatus::Ended`, the `timer_end` is reset to 0, and a `GameEnded` event is
        ///     emitted.
        ///   - If there are more questions, the `game.current_question` index is incremented. The
        ///     next `Question` model is read using the `trivia_id` and the new `current_question`
        ///     index. The `timer_end` for the next question is set to the current block timestamp
        ///     plus the `time_limit` of the new question.
        /// - Emits a `NextQuestion` event, indicating the index of the current question and the
        ///   `game_id`.
        /// - Persists the updated `Game` model to the world state.
        ///
        /// # Arguments
        ///
        /// * `game_id`: The unique identifier (`u64`) of the game session to advance.
        ///
        /// # Panics
        ///
        /// This function will panic with the following errors:
        /// - `INVALID_GAME_STATUS`: If the game specified by `game_id` is not currently in the
        ///   `InProgress` state.
        /// - `UNAUTHORIZED`: If the caller is neither the game host nor is the current block
        ///   timestamp after the `timer_end` of the current question.
        fn next_question(
            ref self: ContractState, game_id: u64,
        ) { // Obtain a mutable reference to the contract's default world state.
        // Retrieve the address of the user who is calling this function.

        // Read the `Game` model using the provided `game_id`.

        // Assert that the game is currently in the `InProgress` state.

        // Assert that either the caller is the host or the time for the current question has
        // expired.

        // Read the `TriviaInfo` model to get the total number of questions.

        // Check if all questions have been presented.

        // If so, end the game.

        // Otherwise, advance to the next question.

        // Read the next question.

        // Set the timer for the next question.

        // Emit an event indicating the next question.

        // Update the `Game` model in the world state.

        }

        /// Retrieves the current leaderboard for a specific trivia game.
        ///
        /// This view function fetches and returns a list of players and their scores in a given
        /// game session. It performs the following actions:
        /// - Accesses the contract's default world state (read-only).
        /// - Reads the `Game` model associated with the provided `game_id` to get the number of
        ///   players.
        /// - Initializes an empty array to store player addresses and their scores.
        /// - Iterates through each player in the game, based on the `player_count` in the `Game`
        ///   model (starting from player ID 1).
        /// - For each player ID:
        ///   - Reads the `PlayerBoard` model to get the contract address of the player associated
        ///     with that ID in the game.
        ///   - Reads the `Player` model using the `game_id` and the player's contract address to
        ///     retrieve their current score.
        ///   - Appends a tuple containing the player's address and their score to the `scores`
        ///     array.
        /// - Finally, converts the `scores` array into a `Span`, which is an immutable view of a
        ///   contiguous sequence of elements, suitable for returning from a view function.
        ///
        /// # Arguments
        ///
        /// * `game_id`: The unique identifier (`u64`) of the game session for which to retrieve the
        ///   leaderboard.
        ///
        /// # Returns
        ///
        /// A `Span` of tuples, where each tuple contains:
        /// - The `ContractAddress` of a player in the game.
        /// - The player's current score (`u32`).
        fn view_leader_board(
            self: @ContractState, game_id: u64,
        ) -> Span<
            (ContractAddress, u32),
        > { // Obtain a read-only reference to the contract's default world state.
            // Read the `Game` model to get the number of players in the game.

            // Initialize an empty array to store player addresses and their scores.

            // Iterate through each player in the game, based on the player count.

            // Read the `PlayerBoard` model to get the address of the player with the current
            // ID.

            // Read the `Player` model to get the player's score.

            // Append the player's address and score to the `scores` array.

            // Convert the `scores` array into a `Span` for returning.
            array![(get_caller_address(), 0)].span()
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        /// Retrieves the default world storage for the contract.
        ///
        /// This function returns a `WorldStorage` instance associated with the
        /// namespace "synapz". This world storage is used to interact with the
        /// game's data and entities.
        ///
        /// # Arguments
        ///
        /// * `self`: A shared reference to the contract's state.
        ///
        /// # Returns
        ///
        /// A `WorldStorage` instance.
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"synapz")
        }

        /// Generates a unique identifier for a given resource.
        ///
        /// This function retrieves a counter associated with the specified `resource`,
        /// increments it, updates the counter in the world storage, and returns the
        /// new unique identifier. This ensures that each resource instance has a distinct ID.
        ///
        /// # Arguments
        ///
        /// * `self`: A mutable reference to the contract's state.
        /// * `resource`: A `felt252` representing the name or identifier of the resource
        ///               for which a unique ID is needed (e.g., 'trivia_counter', 'game_counter').
        ///
        /// # Returns
        ///
        /// A unique identifier (`u64`) for the resource.
        fn resource_uid(ref self: ContractState, resource: felt252) -> u64 {
            let mut world = self.world_default();
            let mut resource_counter: ResourceCounter = world.read_model(resource);
            let resource_id = resource_counter.current_val + 1;
            resource_counter.current_val = resource_id;
            world.write_model(@resource_counter);
            resource_id
        }
    }
}

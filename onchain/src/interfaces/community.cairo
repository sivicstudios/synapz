use starknet::ContractAddress;

/// Defines the interface for interacting with the community game mode.
///
/// This interface outlines the functions that can be called on a contract
/// implementing the community-driven trivia game logic.
#[starknet::interface]
pub trait ICommunityGameMode<T> {
    /// Creates a new trivia game.
    ///
    /// Initializes a new trivia game with a unique identifier and sets the
    /// caller as the owner.
    ///
    /// # Returns
    ///
    /// A unique identifier (`u64`) for the newly created trivia game.
    fn create_trivia(ref self: T) -> u64;

    /// Adds a new question to an existing trivia game.
    ///
    /// Allows the owner of a trivia game to add questions with their
    /// corresponding text, options, correct answer, and time limit.
    ///
    /// # Arguments
    ///
    /// * `trivia_id`: The unique identifier of the trivia game to add the question to.
    /// * `text`: The text content of the question.
    /// * `options`: The available answer options, encoded in a specific format.
    /// * `correct_answer`: The index of the correct answer among the options.
    /// * `time_limit`: The time limit in seconds for players to answer this question.
    fn add_question(
        ref self: T,
        trivia_id: u64,
        text: felt252,
        options: felt252,
        correct_answer: u8,
        time_limit: u8,
    );

    /// Creates a new instance of a trivia game for players to join.
    ///
    /// Takes an existing trivia game definition and creates a playable game instance.
    ///
    /// # Arguments
    ///
    /// * `trivia_id`: The unique identifier of the trivia game definition to instantiate.
    ///
    /// # Returns
    ///
    /// A unique identifier (`u64`) for the newly created game instance.
    fn create_game(ref self: T, trivia_id: u64) -> u64;

    /// Allows a player to join a specific game instance.
    ///
    /// Players can join games that are in the 'Lobby' status.
    ///
    /// # Arguments
    ///
    /// * `game_id`: The unique identifier of the game instance to join.
    fn join_game(ref self: T, game_id: u64);

    /// Starts a game instance, transitioning its status from 'Lobby' to 'InProgress'.
    ///
    /// This function likely initiates the game timer and presents the first question.
    ///
    /// # Arguments
    ///
    /// * `game_id`: The unique identifier of the game instance to start.
    fn start_game(ref self: T, game_id: u64);

    /// Allows a player to submit their answer to the current question in a game.
    ///
    /// Records the player's answer and checks if it is correct.
    ///
    /// # Arguments
    ///
    /// * `game_id`: The unique identifier of the game instance.
    /// * `answer_index`: The index of the answer chosen by the player.
    fn submit_answer(ref self: T, game_id: u64, answer_index: u8);

    /// Advances the game to the next question.
    ///
    /// This function likely checks if there are more questions available and updates
    /// the game state accordingly. If all questions have been answered, the game might end.
    ///
    /// # Arguments
    ///
    /// * `game_id`: The unique identifier of the game instance.
    fn next_question(ref self: T, game_id: u64);

    /// Retrieves the leaderboard for a specific game instance.
    ///
    /// Returns a list of players and their scores, typically sorted in descending order of score.
    ///
    /// # Arguments
    ///
    /// * `game_id`: The unique identifier of the game instance.
    ///
    /// # Returns
    ///
    /// A span of tuples, where each tuple contains the `ContractAddress` of a player
    /// and their corresponding `u32` score.
    fn view_leader_board(self: @T, game_id: u64) -> Span<(ContractAddress, u32)>;
}

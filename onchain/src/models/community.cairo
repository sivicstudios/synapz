use starknet::ContractAddress;

/// Represents the different states a game can be in.
#[derive(Copy, Drop, Serde, Debug, Introspect, PartialEq)]
pub enum GameStatus {
    /// The game is currently in the lobby, waiting for players to join.
    Lobby,
    /// The game is in progress, and questions are being presented to players.
    InProgress,
    /// The game has ended, and no further actions can be taken.
    Ended,
}

/// Implementation to convert `GameStatus` enum to a `felt252` value.
impl GameStateIntoFelt252 of Into<GameStatus, felt252> {
    fn into(self: GameStatus) -> felt252 {
        match self {
            GameStatus::Lobby => 0,
            GameStatus::InProgress => 1,
            GameStatus::Ended => 2,
        }
    }
}

/// Represents a trivia game.
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Trivia {
    /// The unique identifier for the trivia game.
    #[key]
    pub trivia_id: u64,
    /// The address of the contract that owns this trivia game.
    pub owner: ContractAddress,
}

/// Stores general information about a trivia game.
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct TriviaInfo {
    /// The unique identifier for the associated trivia game.
    #[key]
    pub trivia_id: u64,
    /// The total number of questions associated with this trivia game.
    pub question_count: u8,
}

/// Represents a single question within a trivia game.
#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct Question {
    /// The unique identifier of the trivia game this question belongs to.
    #[key]
    pub trivia_id: u64,
    /// The time limit in seconds for answering this question.
    #[key]
    pub time_limit: u8,
    /// The index of this question within the trivia game.
    pub question_index: u8,
    /// The index of the correct answer among the options.
    pub correct_answer: u8,
    /// The text content of the question.
    pub text: felt252,
    /// The available answer options, likely encoded in a specific format.
    pub options: felt252,
}

/// Represents an active instance of a trivia game.
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Game {
    /// The unique identifier for this specific game instance.
    #[key]
    pub game_id: u64,
    /// The identifier of the trivia game definition this instance is based on.
    pub trivia_id: u64,
    /// The address of the player who initiated or hosts this game.
    pub host: ContractAddress,
    /// The current status of the game (Lobby, InProgress, Ended).
    pub status: GameStatus,
    /// The index of the currently active question.
    pub current_question: u8,
    /// The timestamp at which the current question's timer ends.
    pub timer_end: u64,
    /// The number of players currently participating in the game.
    pub player_count: u16,
}

/// Represents a player participating in a specific game.
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Player {
    /// The unique identifier of the game the player is participating in.
    #[key]
    pub game_id: u64,
    /// The address of the player's contract.
    #[key]
    pub player_address: ContractAddress,
    /// The player's current score in the game.
    pub score: u32,
    /// The player's current consecutive correct answer streak.
    pub streak: u8,
    /// The timestamp of the player's last submitted answer.
    pub last_answer_time: u64,
}

/// Represents a player's entry on the game's leaderboard.
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct PlayerBoard {
    /// The unique identifier of the game the leaderboard belongs to.
    #[key]
    pub game_id: u64,
    /// A unique identifier for the player's entry on the leaderboard.
    #[key]
    pub player_id: u16,
    /// The address of the player.
    pub player: ContractAddress,
}

/// Represents a player's answer to a specific question in a game.
#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Answer {
    /// The unique identifier of the game the answer belongs to.
    #[key]
    pub game_id: u64,
    /// The index of the question being answered.
    #[key]
    pub question_index: u8,
    /// The address of the player who submitted the answer.
    #[key]
    pub player_address: ContractAddress,
    /// The index of the answer chosen by the player.
    pub answer_index: u8,
    /// A boolean indicating whether the submitted answer was correct.
    pub is_correct: bool,
    /// The timestamp at which the answer was submitted.
    pub timestamp: u64,
}

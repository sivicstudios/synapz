use starknet::ContractAddress;

/// Emitted when a new trivia game definition is created.
#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct TriviaCreated {
    /// The unique identifier of the newly created trivia game.
    #[key]
    pub trivia_id: u64,
    /// The address of the contract that created the trivia game (the host).
    pub host: ContractAddress,
    /// The timestamp at which the trivia game was created.
    pub timestamp: u64,
}

/// Emitted when a new instance of a trivia game is created for playing.
#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct GameCreated {
    /// The unique identifier of the newly created game instance.
    #[key]
    pub game_id: u64,
    /// The address of the contract that initiated the game instance (the host).
    pub host: ContractAddress,
    /// The timestamp at which the game instance was created.
    pub timestamp: u64,
}

/// Emitted when a new question is added to a trivia game definition.
#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct QuestionAdded {
    /// The unique identifier of the trivia game the question was added to.
    #[key]
    pub trivia_id: u64,
    /// The index of the newly added question within the trivia game.
    pub question_index: u8,
}

/// Emitted when a player successfully joins a game instance.
#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct PlayerJoined {
    /// The unique identifier of the game instance the player joined.
    #[key]
    pub game_id: u64,
    /// The address of the player who joined the game.
    #[key]
    pub player_address: ContractAddress,
    /// The timestamp at which the player joined the game.
    pub timestamp: u64,
}

/// Emitted when a game instance is started.
#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct GameStarted {
    /// The unique identifier of the game instance that has started.
    #[key]
    pub game_id: u64,
    /// The timestamp at which the game started.
    pub timestamp: u64,
}

/// Emitted when a player submits an answer to a question in a game.
#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct AnswerSubmitted {
    /// The unique identifier of the game instance.
    #[key]
    pub game_id: u64,
    /// The address of the player who submitted the answer.
    #[key]
    pub player_address: ContractAddress,
    /// The index of the answer submitted by the player.
    pub answer_index: felt252,
    /// The score awarded to the player for this answer.
    pub score_awarded: u32,
}

/// Emitted when the game progresses to the next question.
#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct NextQuestion {
    /// The unique identifier of the game instance.
    #[key]
    pub game_id: u64,
    /// The index of the current question being presented.
    pub current_question_index: u32,
}

/// Emitted when a game instance ends.
#[derive(Copy, Drop, Serde)]
#[dojo::event]
pub struct GameEnded {
    /// The unique identifier of the game instance that has ended.
    #[key]
    pub game_id: u64,
    /// The timestamp at which the game ended.
    pub timestamp: u64,
}

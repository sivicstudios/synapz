/// ResourceCounter
/// Represents a counter for the number of games played.
#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
#[dojo::model]
pub struct ResourceCounter {
    /// The unique identifier for the counter (e.g., a constant string).
    #[key]
    pub id: felt252,
    /// The current value of the counter.
    pub current_val: u64,
}

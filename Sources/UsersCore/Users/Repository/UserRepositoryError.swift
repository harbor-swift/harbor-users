package enum UserRepositoryError: Error, Equatable {
    /// A user with this id exists under another name.
    case idempotencyConflict
}

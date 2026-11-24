package enum CreateUserUseCaseError: Error, Equatable {
    case invalidDisplayName
    case idempotencyConflict
    case unknown
}

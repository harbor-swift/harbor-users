import UsersCore

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Answers the user the input names, or throws the error it was given.
struct MockCreateUserUseCase: CreateUserUseCaseProtocol {
    var error: CreateUserUseCaseError?

    func callAsFunction(input: CreateUserUseCaseInput) async throws(CreateUserUseCaseError) -> User {
        if let error {
            throw error
        }

        return User(id: input.id, displayName: input.displayName, creationDate: .now)
    }
}

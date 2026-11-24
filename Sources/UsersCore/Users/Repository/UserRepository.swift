#if canImport(FoundationEssentials)
package import FoundationEssentials
#else
package import Foundation
#endif

/// The persistence of users.
package protocol UserRepository: Sendable {
    /// Creates the user, or returns the one an earlier request with the same id and name created.
    func create(_ command: CreateUserCommand) async throws -> User
    func user(id: UUID) async throws -> User?
}

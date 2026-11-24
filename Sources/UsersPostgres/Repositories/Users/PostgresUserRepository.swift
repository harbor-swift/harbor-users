import AsyncAlgorithms
import Logging
import PostgresNIO
import UsersCore

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

struct PostgresUserRepository: UserRepository {
    let connection: PostgresConnection
    let logger: Logger

    func create(_ command: CreateUserCommand) async throws -> User {
        let statement = CreateUserStatement(command: command)
        let rows = try await connection.execute(statement, logger: logger)
        let users = try await Array(rows)
        // The id's user exists under another name, so the conflict's update matched no row.
        guard let user = users.first else {
            throw UserRepositoryError.idempotencyConflict
        }

        return user
    }

    func user(id: UUID) async throws -> User? {
        let statement = UserByIDStatement(id: id)
        let rows = try await connection.execute(statement, logger: logger)
        let users = try await Array(rows)
        return users.first
    }
}

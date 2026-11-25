// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

package import Logging
package import Persistence

/// Creates the user whose address Auth has verified, under their account's id; a repeat returns the user.
///
/// Auth's worker calls it, admitted by its certificate, naming the user it acts for, and retries it until it
/// lands: the id is the create's idempotency key. Runs on `users_internal`: no caller is bound, so the tenant
/// policy would hide every row.
package struct CreateUserUseCase<DatabaseType>: CreateUserUseCaseProtocol
where DatabaseType: Database, DatabaseType.Scope: CreateUserUseCaseScope {
    private let database: DatabaseType
    private let logger: Logger

    package init(database: DatabaseType, logger: Logger) {
        self.database = database
        self.logger = logger
    }

    package func callAsFunction(input: CreateUserUseCaseInput) async throws(CreateUserUseCaseError) -> User {
        guard !input.displayName.isEmpty else {
            throw .invalidDisplayName
        }

        do {
            // A retry gets back the user its first attempt created.
            let command = CreateUserCommand(id: input.id, displayName: input.displayName)
            let user = try await database.withTransaction { scope in
                try await scope.userRepository.create(command)
            }
            logger.info("User created", metadata: ["userID": "\(user.id)"])
            return user
        } catch UserRepositoryError.idempotencyConflict {
            logger.warning("Creating the user refused: the id belongs to a user with another name")
            throw .idempotencyConflict
        } catch is CancellationError {
            throw .unknown
        } catch {
            logger.error("Creating the user failed: unknown error", metadata: ["error": "\(error)"])
            throw .unknown
        }
    }
}

// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

package import HarborAuthentication
package import Logging
package import Persistence

/// The caller's own user.
///
/// The token names the user, so no request does. Runs on `users_service`, where the tenant policy confines the
/// transaction to the caller's row as well.
package struct GetUserUseCase<DatabaseType>: GetUserUseCaseProtocol
where DatabaseType: Database, DatabaseType.Scope: GetUserUseCaseScope {
    private let database: DatabaseType
    private let logger: Logger

    package init(database: DatabaseType, logger: Logger) {
        self.database = database
        self.logger = logger
    }

    package func callAsFunction(subject: UserIdentity) async throws(GetUserUseCaseError) -> User {
        do {
            let user = try await database.withTransaction { scope in
                try await scope.userRepository.user(id: subject.userID)
            }
            // A verified person's user appears once their registration completes.
            guard let user else {
                throw GetUserUseCaseError.userNotFound
            }

            return user
        } catch let error as GetUserUseCaseError {
            throw error
        } catch is CancellationError {
            throw .unknown
        } catch {
            logger.error("Reading the user failed: unknown error", metadata: ["error": "\(error)"])
            throw .unknown
        }
    }
}

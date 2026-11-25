// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

package import Logging
package import PersistencePostgres
package import PostgresNIO
package import UsersCore

/// A unit of work as `users_internal`, which sees every user: its use cases name the user they act for.
package struct PostgresUsersInternalScope: PostgresScope, CreateUserUseCaseScope {
    package let userRepository: any UserRepository

    package init(connection: PostgresConnection, logger: Logger) {
        self.userRepository = PostgresUserRepository(connection: connection, logger: logger)
    }
}

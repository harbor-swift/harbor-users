// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

package import Logging
package import PersistencePostgres
package import PostgresNIO
package import UsersCore

/// A unit of work as `users_service`, whose policy narrows `users` to the bound caller's row.
package struct PostgresUsersScope: PostgresScope, GetUserUseCaseScope {
    package let userRepository: any UserRepository

    package init(connection: PostgresConnection, logger: Logger) {
        self.userRepository = PostgresUserRepository(connection: connection, logger: logger)
    }
}

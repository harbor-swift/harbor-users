// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

package import Logging
package import PostgresMigrations
package import PostgresNIO

/// Users, each under the id Auth gave their account, which is also the create's idempotency key.
package struct CreateUsersTable: DatabaseMigration {
    package init() {}

    package func apply(connection: PostgresConnection, logger: Logger) async throws {
        try await connection.query(
            """
            CREATE TABLE users (
                id UUID NOT NULL,
                display_name TEXT NOT NULL,
                creation_date TIMESTAMPTZ NOT NULL DEFAULT now(),
                CONSTRAINT users_pkey PRIMARY KEY (id)
            )
            """,
            logger: logger
        )
    }

    package func revert(connection: PostgresConnection, logger: Logger) async throws {
        try await connection.query("DROP TABLE IF EXISTS users", logger: logger)
    }
}

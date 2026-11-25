// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

package import Logging
package import PostgresMigrations
package import PostgresNIO

/// Confines `users_service` to the bound caller's user, and lets `users_internal` see every one.
package struct CreateUsersRLSPolicy: DatabaseMigration {
    private let internalRole: String

    package init(internalRole: String) {
        self.internalRole = internalRole
    }

    package func apply(connection: PostgresConnection, logger: Logger) async throws {
        let internalRole = "\"" + self.internalRole.replacing("\"", with: "\"\"") + "\""
        try await connection.query("ALTER TABLE users ENABLE ROW LEVEL SECURITY", logger: logger)
        // NULLIF: a pooled connection that once carried the setting reads '' after, and ''::uuid is an error.
        try await connection.query(
            """
            CREATE POLICY tenant_isolation ON users
                USING (id = (SELECT NULLIF(current_setting('app.caller_user_id', true), '')::uuid))
            """,
            logger: logger
        )
        let internalPolicy = PostgresQuery(
            unsafeSQL: "CREATE POLICY internal_all ON users TO \(internalRole) USING (true)"
        )
        try await connection.query(internalPolicy, logger: logger)
    }

    package func revert(connection: PostgresConnection, logger: Logger) async throws {
        try await connection.query("DROP POLICY IF EXISTS internal_all ON users", logger: logger)
        try await connection.query("DROP POLICY IF EXISTS tenant_isolation ON users", logger: logger)
        try await connection.query("ALTER TABLE users DISABLE ROW LEVEL SECURITY", logger: logger)
    }
}

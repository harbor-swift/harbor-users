package import Logging
package import PostgresMigrations
package import PostgresNIO

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A login role that reads and writes rows, never `TRUNCATE`, and gets the same on every table later migrations
/// create. `Migrations.apply()` sets its password from its file after the list runs.
package struct CreateServiceRole: DatabaseMigration {
    private let role: String
    private let database: String

    package init(role: String, database: String) {
        self.role = role
        self.database = database
    }

    package func apply(connection: PostgresConnection, logger: Logger) async throws {
        // Role and database names take no bindings, so they're quoted as identifiers from configuration.
        let role = "\"" + self.role.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        let database = "\"" + self.database.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        let statements = [
            "CREATE ROLE \(role) LOGIN",
            "GRANT CONNECT ON DATABASE \(database) TO \(role)",
            "GRANT USAGE ON SCHEMA public TO \(role)",
            "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \(role)",
            "GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO \(role)",
            "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO \(role)",
            "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO \(role)",
        ]
        for statement in statements {
            let query = PostgresQuery(unsafeSQL: statement)
            try await connection.query(query, logger: logger)
        }
    }

    package func revert(connection: PostgresConnection, logger: Logger) async throws {
        let role = "\"" + self.role.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        let dropOwned = PostgresQuery(unsafeSQL: "DROP OWNED BY \(role)")
        let dropRole = PostgresQuery(unsafeSQL: "DROP ROLE IF EXISTS \(role)")
        try await connection.query(dropOwned, logger: logger)
        try await connection.query(dropRole, logger: logger)
    }
}

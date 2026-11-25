// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import Logging
import PostgresMigrations
import PostgresNIO
import UsersPostgres

/// Applies Users' migrations as the database's owner, then sets each role's password.
struct Migrations {
    private let client: PostgresClient
    private let database: String
    private let serviceRole: DatabaseRole
    private let internalRole: DatabaseRole
    private let logger: Logger

    init(
        client: PostgresClient,
        database: String,
        serviceRole: DatabaseRole,
        internalRole: DatabaseRole,
        logger: Logger
    ) {
        self.client = client
        self.database = database
        self.serviceRole = serviceRole
        self.internalRole = internalRole
        self.logger = logger
    }

    func apply() async throws {
        let migrations = DatabaseMigrations()
        let all = UsersMigrations.all(
            database: database,
            serviceRole: serviceRole.name,
            internalRole: internalRole.name
        )
        await migrations.add(contentsOf: all)
        // A rolled-back image starts on a schema holding migrations its list lacks.
        try await migrations.apply(client: client, options: .ignoreUnknownMigrations, logger: logger, dryRun: false)

        // A migration runs once, so a role's password is set on every run: rotating it is a configuration change.
        for role in [serviceRole, internalRole] {
            let name = "\"" + role.name.replacing("\"", with: "\"\"") + "\""
            let password = "'" + role.password.replacing("'", with: "''") + "'"
            let setPassword = PostgresQuery(unsafeSQL: "ALTER ROLE \(name) PASSWORD \(password)")
            try await client.query(setPassword, logger: logger)
        }
    }
}

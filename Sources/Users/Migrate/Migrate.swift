// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import ArgumentParser
import Configuration
import HarborPersistence
import Logging
import PersistencePostgres
import PostgresNIO

struct Migrate: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "migrate",
        abstract: "Apply pending database migrations, then exit"
    )

    func run() async throws {
        // MARK: - Configuration
        let config = ConfigReader(providers: [
            EnvironmentVariablesProvider(),
            InMemoryProvider.applicationDefaults,
        ])

        // MARK: - Logging
        let logLevel = config.string(forKey: "logLevel", as: Logger.Level.self, default: .info)
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = logLevel
            return handler
        }
        let logger = Logger(label: "harbor-users-migrator")

        // MARK: - Infrastructure
        let postgresConfig = config.scoped(to: "postgres")
        let ownerPostgresConfiguration = try PostgresClient.Configuration(config: postgresConfig, role: "owner")
        let database = try postgresConfig.requiredString(forKey: "db")
        let serviceRoleConfig = postgresConfig.scoped(to: "service")
        let serviceRole = try DatabaseRole(config: serviceRoleConfig)
        let internalRoleConfig = postgresConfig.scoped(to: "internal")
        let internalRole = try DatabaseRole(config: internalRoleConfig)

        // MARK: - Composition
        try await PostgresClient.withClient(configuration: ownerPostgresConfiguration, logger: logger) { client in
            let migrations = Migrations(
                client: client,
                database: database,
                serviceRole: serviceRole,
                internalRole: internalRole,
                logger: logger
            )
            try await migrations.apply()
        }
        logger.info("Migrations applied")
    }
}

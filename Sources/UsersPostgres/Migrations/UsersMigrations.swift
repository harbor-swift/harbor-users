// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

package import PostgresMigrations

/// Every migration of Users' database, in applied order. Append only.
package enum UsersMigrations {
    package static func all(database: String, serviceRole: String, internalRole: String) -> [any DatabaseMigration] {
        let createServiceRole = CreateServiceRole(role: serviceRole, database: database)
        let createInternalRole = CreateInternalRole(role: internalRole, database: database)
        let createUsersTable = CreateUsersTable()
        let createUsersRLSPolicy = CreateUsersRLSPolicy(internalRole: internalRole)
        return [createServiceRole, createInternalRole, createUsersTable, createUsersRLSPolicy]
    }
}

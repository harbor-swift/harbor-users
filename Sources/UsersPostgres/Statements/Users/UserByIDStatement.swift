// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import PostgresNIO
import UsersCore

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Names the user in its own `WHERE`, so it confines the read on the internal role, which sees every row.
struct UserByIDStatement: PostgresPreparedStatement {
    static let sql = """
        SELECT id, display_name, creation_date
        FROM users
        WHERE id = $1
        """

    let id: UUID

    func makeBindings() throws -> PostgresBindings {
        var bindings = PostgresBindings()
        bindings.append(id)
        return bindings
    }

    func decodeRow(_ row: PostgresRow) throws -> User {
        try User(row: row)
    }
}

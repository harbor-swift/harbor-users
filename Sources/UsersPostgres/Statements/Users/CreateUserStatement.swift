// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import PostgresNIO
import UsersCore

/// Creates a user, or returns the one an earlier request with the same id and name created.
struct CreateUserStatement: PostgresPreparedStatement {
    static let sql = """
        INSERT INTO users (id, display_name)
        VALUES ($1, $2)
        ON CONFLICT ON CONSTRAINT users_pkey DO UPDATE
            SET id = EXCLUDED.id
            WHERE users.display_name = EXCLUDED.display_name
        RETURNING id, display_name, creation_date
        """

    let command: CreateUserCommand

    func makeBindings() throws -> PostgresBindings {
        var bindings = PostgresBindings()
        bindings.append(command.id)
        bindings.append(command.displayName)
        return bindings
    }

    func decodeRow(_ row: PostgresRow) throws -> User {
        try User(row: row)
    }
}

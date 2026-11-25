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

extension User {
    /// Decodes `id, display_name, creation_date`.
    init(row: PostgresRow) throws {
        let (id, displayName, creationDate) = try row.decode((UUID, String, Date).self)
        self.init(id: id, displayName: displayName, creationDate: creationDate)
    }
}

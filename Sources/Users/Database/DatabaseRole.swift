// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

/// A login role of Users' database, and the password the deployment gave it.
struct DatabaseRole: Sendable {
    let name: String
    let password: String
}

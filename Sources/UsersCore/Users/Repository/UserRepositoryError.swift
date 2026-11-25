// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

package enum UserRepositoryError: Error, Equatable {
    /// A user with this id exists under another name.
    case idempotencyConflict
}

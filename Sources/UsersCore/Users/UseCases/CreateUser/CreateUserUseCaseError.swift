// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

package enum CreateUserUseCaseError: Error, Equatable {
    case invalidDisplayName
    case idempotencyConflict
    case unknown
}

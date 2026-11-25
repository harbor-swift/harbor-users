// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

package protocol CreateUserUseCaseProtocol: Sendable {
    /// Creates the user whose address Auth has verified, under their account's id; a repeat returns the user.
    func callAsFunction(input: CreateUserUseCaseInput) async throws(CreateUserUseCaseError) -> User
}

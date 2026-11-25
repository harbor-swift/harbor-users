// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

package import HarborAuthentication

package protocol GetUserUseCaseProtocol: Sendable {
    /// The caller's own user.
    func callAsFunction(subject: UserIdentity) async throws(GetUserUseCaseError) -> User
}

// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import HarborAuthentication
import UsersCore

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Answers the subject's user, or throws the error it was given.
struct MockGetUserUseCase: GetUserUseCaseProtocol {
    var error: GetUserUseCaseError?

    func callAsFunction(subject: UserIdentity) async throws(GetUserUseCaseError) -> User {
        if let error {
            throw error
        }

        return User(id: subject.userID, displayName: "Ada", creationDate: .now)
    }
}

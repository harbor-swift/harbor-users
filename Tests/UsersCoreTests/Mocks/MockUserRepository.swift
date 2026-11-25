// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import Synchronization
import UsersCore

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Answers reads with the user it was given, records each create, and throws what it was told to.
final class MockUserRepository: UserRepository {
    private let existingUser: User?
    private let createError: UserRepositoryError?
    private let created = Mutex<[CreateUserCommand]>([])

    init(existingUser: User? = nil, createError: UserRepositoryError? = nil) {
        self.existingUser = existingUser
        self.createError = createError
    }

    var createdUsers: [CreateUserCommand] {
        created.withLock { $0 }
    }

    func create(_ command: CreateUserCommand) async throws -> User {
        created.withLock { $0.append(command) }
        if let createError {
            throw createError
        }

        return User(id: command.id, displayName: command.displayName, creationDate: .now)
    }

    func user(id: UUID) async throws -> User? {
        existingUser
    }
}

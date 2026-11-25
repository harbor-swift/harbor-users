// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import HarborTesting
import Logging
import Testing
import UsersCore

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

struct CreateUserUseCaseTests {
    private let input = CreateUserUseCaseInput(id: UUID(), displayName: "Ada")

    @Test("Creates the user Auth asks for, under its account's id")
    func createsUser() async throws {
        let repository = MockUserRepository()
        let scope = MockUsersScope(userRepository: repository)
        let database = MockDatabase(scope: scope)
        let createUser = CreateUserUseCase(database: database, logger: Logger(label: "test"))

        let user = try await createUser(input: input)

        #expect(user.id == input.id)
        #expect(user.displayName == "Ada")
        #expect(repository.createdUsers.map(\.id) == [input.id])
    }

    @Test("Refuses a user without a display name, before touching the database")
    func refusesEmptyDisplayName() async {
        let repository = MockUserRepository()
        let scope = MockUsersScope(userRepository: repository)
        let database = MockDatabase(scope: scope)
        let createUser = CreateUserUseCase(database: database, logger: Logger(label: "test"))
        let emptyNameInput = CreateUserUseCaseInput(id: UUID(), displayName: "")

        await #expect(throws: CreateUserUseCaseError.invalidDisplayName) {
            try await createUser(input: emptyNameInput)
        }
        #expect(repository.createdUsers.isEmpty)
    }

    @Test("An id whose user has another name is an idempotency conflict")
    func mapsIdempotencyConflict() async {
        let repository = MockUserRepository(createError: .idempotencyConflict)
        let scope = MockUsersScope(userRepository: repository)
        let database = MockDatabase(scope: scope)
        let createUser = CreateUserUseCase(database: database, logger: Logger(label: "test"))

        await #expect(throws: CreateUserUseCaseError.idempotencyConflict) {
            try await createUser(input: input)
        }
    }
}

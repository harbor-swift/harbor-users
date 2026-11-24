import HarborAuthentication
import HarborTesting
import Logging
import Testing
import UsersCore

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

struct GetUserUseCaseTests {
    private let subject = UserIdentity(
        userID: UUID(),
        role: .user,
        issuer: "harbor-auth",
        issueDate: .now,
        expirationDate: Date.now.addingTimeInterval(900)
    )

    @Test("Answers the caller's own user")
    func readsCallersUser() async throws {
        let existingUser = User(id: subject.userID, displayName: "Ada", creationDate: .now)
        let scope = MockUsersScope(userRepository: MockUserRepository(existingUser: existingUser))
        let database = MockDatabase(scope: scope)
        let getUser = GetUserUseCase(database: database, logger: Logger(label: "test"))

        let user = try await getUser(subject: subject)

        #expect(user == existingUser)
    }

    @Test("A caller whose registration hasn't completed has no user yet")
    func mapsMissingUser() async {
        let scope = MockUsersScope(userRepository: MockUserRepository())
        let database = MockDatabase(scope: scope)
        let getUser = GetUserUseCase(database: database, logger: Logger(label: "test"))

        await #expect(throws: GetUserUseCaseError.userNotFound) {
            try await getUser(subject: subject)
        }
    }
}

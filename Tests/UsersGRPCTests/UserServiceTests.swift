import Authentication
import GRPCCore
import HarborAuthentication
import OperationContext
import Testing
import UsersCore
import UsersGRPC
import UsersProtos

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

struct UserServiceTests {
    private let context = ServerContext(
        descriptor: Harbor_Users_V1_UserService.Method.GetUser.descriptor,
        remotePeer: "in-process",
        localPeer: "in-process",
        cancellation: ServerContext.RPCCancellationHandle()
    )
    private let identity = UserIdentity(
        userID: UUID(),
        role: .user,
        issuer: "harbor-auth",
        issueDate: .now,
        expirationDate: Date.now.addingTimeInterval(900)
    )

    private func withCaller<T: Sendable>(_ operation: () async throws -> T) async throws -> T {
        var operationContext = OperationContext()
        operationContext.user = Principal(identity: identity, credential: "token")
        return try await OperationContext.withContext(operationContext, operation: operation)
    }

    @Test("Answers the bound caller's user")
    func readsCallersUser() async throws {
        let service = UserService(getUserUseCase: MockGetUserUseCase())

        let user = try await withCaller {
            try await service.getUser(request: Harbor_Users_V1_GetUserRequest(), context: context)
        }

        #expect(user.id == identity.userID.uuidString.lowercased())
        #expect(user.displayName == "Ada")
        #expect(user.hasCreationDate)
    }

    @Test("Requires a caller")
    func requiresCaller() async {
        let service = UserService(getUserUseCase: MockGetUserUseCase())

        let error = await #expect(throws: RPCError.self) {
            try await service.getUser(request: Harbor_Users_V1_GetUserRequest(), context: context)
        }

        #expect(error?.code == .unauthenticated)
    }

    @Test(
        "Maps each of the use case's errors to its status",
        arguments: [
            (GetUserUseCaseError.userNotFound, RPCError.Code.notFound),
            (GetUserUseCaseError.unknown, RPCError.Code.internalError),
        ]
    )
    func mapsErrors(useCaseError: GetUserUseCaseError, code: RPCError.Code) async {
        let service = UserService(getUserUseCase: MockGetUserUseCase(error: useCaseError))

        let error = await #expect(throws: RPCError.self) {
            try await withCaller {
                try await service.getUser(request: Harbor_Users_V1_GetUserRequest(), context: context)
            }
        }

        #expect(error?.code == code)
    }
}

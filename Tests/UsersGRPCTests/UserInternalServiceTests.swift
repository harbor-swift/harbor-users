// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import GRPCCore
import Testing
import UsersCore
import UsersGRPC
import UsersProtos

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

struct UserInternalServiceTests {
    private let context = ServerContext(
        descriptor: Harbor_Users_V1_UserInternalService.Method.CreateUser.descriptor,
        remotePeer: "in-process",
        localPeer: "in-process",
        cancellation: ServerContext.RPCCancellationHandle()
    )
    private let userID = UUID()

    private var request: Harbor_Users_V1_CreateUserRequest {
        var request = Harbor_Users_V1_CreateUserRequest()
        request.id = userID.uuidString.lowercased()
        request.displayName = "Ada"
        return request
    }

    @Test("Creates the user the request names, requiring no caller")
    func createsUser() async throws {
        let service = UserInternalService(createUserUseCase: MockCreateUserUseCase())

        let user = try await service.createUser(request: request, context: context)

        #expect(user.id == userID.uuidString.lowercased())
        #expect(user.displayName == "Ada")
    }

    @Test("Refuses an id that isn't a UUID")
    func refusesMalformedID() async {
        let service = UserInternalService(createUserUseCase: MockCreateUserUseCase())
        var malformedRequest = request
        malformedRequest.id = "not-a-uuid"

        let error = await #expect(throws: RPCError.self) {
            try await service.createUser(request: malformedRequest, context: context)
        }

        #expect(error?.code == .invalidArgument)
    }

    @Test(
        "Maps each of the use case's errors to its status",
        arguments: [
            (CreateUserUseCaseError.invalidDisplayName, RPCError.Code.invalidArgument),
            (CreateUserUseCaseError.idempotencyConflict, RPCError.Code.failedPrecondition),
            (CreateUserUseCaseError.unknown, RPCError.Code.internalError),
        ]
    )
    func mapsErrors(useCaseError: CreateUserUseCaseError, code: RPCError.Code) async {
        let service = UserInternalService(createUserUseCase: MockCreateUserUseCase(error: useCaseError))

        let error = await #expect(throws: RPCError.self) {
            try await service.createUser(request: request, context: context)
        }

        #expect(error?.code == code)
    }
}

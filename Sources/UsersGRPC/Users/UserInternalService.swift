package import GRPCCore
package import UsersCore
package import UsersProtos

/// Users for other services and workers, admitted by their certificates.
package struct UserInternalService: Harbor_Users_V1_UserInternalService.SimpleServiceProtocol {
    private let createUserUseCase: any CreateUserUseCaseProtocol

    package init(createUserUseCase: any CreateUserUseCaseProtocol) {
        self.createUserUseCase = createUserUseCase
    }

    package func createUser(
        request: Harbor_Users_V1_CreateUserRequest,
        context: ServerContext
    ) async throws -> Harbor_Users_V1_User {
        let input = try CreateUserUseCaseInput(request)

        do {
            let user = try await createUserUseCase(input: input)
            return Harbor_Users_V1_User(user)
        } catch {
            switch error {
            case .invalidDisplayName:
                throw RPCError(code: .invalidArgument, message: "The display name is required.")
            case .idempotencyConflict:
                throw RPCError(code: .failedPrecondition, message: "A user with this id has another name.")
            case .unknown:
                throw RPCError(code: .internalError, message: "The user could not be created.")
            }
        }
    }
}

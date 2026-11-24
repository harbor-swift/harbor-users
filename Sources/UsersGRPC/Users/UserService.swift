import Authentication
package import GRPCCore
import HarborAuthentication
import OperationContext
package import UsersCore
package import UsersProtos

/// Users for people, through the gateway.
///
/// The bearer interceptor identifies the caller when a token is present, and the settings interceptor binds the
/// tenant; each handler requires what its group needs.
package struct UserService: Harbor_Users_V1_UserService.SimpleServiceProtocol {
    private let getUserUseCase: any GetUserUseCaseProtocol

    package init(getUserUseCase: any GetUserUseCaseProtocol) {
        self.getUserUseCase = getUserUseCase
    }

    // MARK: - The caller's own

    package func getUser(
        request: Harbor_Users_V1_GetUserRequest,
        context: ServerContext
    ) async throws -> Harbor_Users_V1_User {
        let subject = try requireUser()

        do {
            let user = try await getUserUseCase(subject: subject)
            return Harbor_Users_V1_User(user)
        } catch {
            switch error {
            case .userNotFound:
                throw RPCError(code: .notFound, message: "The user was not found.")
            case .unknown:
                throw RPCError(code: .internalError, message: "The user could not be read.")
            }
        }
    }

    // MARK: - Caller

    /// The interceptor identifies a user without requiring one; the caller's own RPCs require one.
    private func requireUser() throws -> UserIdentity {
        guard let user = OperationContext.current.user else {
            throw RPCError(code: .unauthenticated, message: "Authentication is required.")
        }

        return user.identity
    }
}

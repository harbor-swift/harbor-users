import GRPCCore
import UsersCore
import UsersProtos

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension CreateUserUseCaseInput {
    init(_ request: Harbor_Users_V1_CreateUserRequest) throws {
        guard let id = UUID(uuidString: request.id) else {
            throw RPCError(code: .invalidArgument, message: "id must be a UUID.")
        }

        self.init(id: id, displayName: request.displayName)
    }
}

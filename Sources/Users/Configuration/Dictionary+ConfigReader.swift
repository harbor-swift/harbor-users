import Configuration
import GRPCCore
import UsersProtos

extension Dictionary where Key == MethodDescriptor, Value == Set<String> {
    /// Each RPC of `UserInternalService`, and the identities of the processes that may call it.
    ///
    /// ## Configuration keys
    /// - `createUser` (string array, required): the callers of `CreateUser`.
    init(config: ConfigReader) throws {
        let createUserCallers = try config.requiredStringArray(forKey: "createUser")
        self = [Harbor_Users_V1_UserInternalService.Method.CreateUser.descriptor: Set(createUserCallers)]
    }
}

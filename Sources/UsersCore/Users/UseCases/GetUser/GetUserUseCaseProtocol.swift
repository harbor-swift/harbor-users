package import HarborAuthentication

package protocol GetUserUseCaseProtocol: Sendable {
    /// The caller's own user.
    func callAsFunction(subject: UserIdentity) async throws(GetUserUseCaseError) -> User
}

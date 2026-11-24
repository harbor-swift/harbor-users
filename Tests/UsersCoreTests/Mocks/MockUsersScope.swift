import UsersCore

struct MockUsersScope: GetUserUseCaseScope, CreateUserUseCaseScope {
    let userRepository: any UserRepository
}

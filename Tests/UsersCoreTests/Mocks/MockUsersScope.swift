// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import UsersCore

struct MockUsersScope: GetUserUseCaseScope, CreateUserUseCaseScope {
    let userRepository: any UserRepository
}

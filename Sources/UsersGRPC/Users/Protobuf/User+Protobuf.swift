// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import SwiftProtobuf
import UsersCore
import UsersProtos

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension Harbor_Users_V1_User {
    init(_ user: User) {
        self.init()
        self.id = user.id.uuidString.lowercased()
        self.displayName = user.displayName
        self.creationDate = Google_Protobuf_Timestamp(date: user.creationDate)
    }
}

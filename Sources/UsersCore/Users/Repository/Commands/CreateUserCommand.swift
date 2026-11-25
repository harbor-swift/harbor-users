// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

#if canImport(FoundationEssentials)
package import FoundationEssentials
#else
package import Foundation
#endif

package struct CreateUserCommand: Sendable {
    package let id: UUID
    package let displayName: String

    package init(id: UUID, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}

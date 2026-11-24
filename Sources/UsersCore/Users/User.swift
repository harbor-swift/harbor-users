#if canImport(FoundationEssentials)
package import FoundationEssentials
#else
package import Foundation
#endif

/// A person as Harbor shows them: the id Auth gave their account, and the name they chose.
package struct User: Equatable, Sendable {
    package let id: UUID
    package let displayName: String
    package let creationDate: Date

    package init(id: UUID, displayName: String, creationDate: Date) {
        self.id = id
        self.displayName = displayName
        self.creationDate = creationDate
    }
}

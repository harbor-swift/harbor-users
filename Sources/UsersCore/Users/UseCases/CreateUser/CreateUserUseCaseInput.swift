#if canImport(FoundationEssentials)
package import FoundationEssentials
#else
package import Foundation
#endif

package struct CreateUserUseCaseInput: Sendable {
    package let id: UUID
    package let displayName: String

    package init(id: UUID, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}

// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import Configuration

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension DatabaseRole {
    /// A role the migrations create, and the password it logs in with.
    ///
    /// ## Configuration keys
    /// - `user` (string, required): the role's name.
    /// - `passwordPath` (string, required): the file holding the role's password, a secret; its first line.
    init(config: ConfigReader) throws {
        let name = try config.requiredString(forKey: "user")
        let passwordPath = try config.requiredString(forKey: "passwordPath")
        let passwordURL = URL(filePath: passwordPath)
        let passwordData = try Data(contentsOf: passwordURL)
        let passwordFile = String(decoding: passwordData, as: UTF8.self)
        let password = String(passwordFile.prefix { !$0.isNewline })
        self.init(name: name, password: password)
    }
}

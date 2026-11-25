// Copyright (c) 2026 Zaid Rahhawi
// SPDX-License-Identifier: MIT
// See LICENSE for license information.

import ArgumentParser

@main
struct Users: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "users",
        abstract: "The Harbor users service: users and their display names",
        subcommands: [
            Serve.self,
            Migrate.self,
        ],
        defaultSubcommand: Serve.self
    )
}

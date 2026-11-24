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

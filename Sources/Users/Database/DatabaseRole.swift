/// A login role of Users' database, and the password the deployment gave it.
struct DatabaseRole: Sendable {
    let name: String
    let password: String
}

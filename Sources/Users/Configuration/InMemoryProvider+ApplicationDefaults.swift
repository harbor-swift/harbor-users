import Configuration

extension InMemoryProvider {
    /// The deployment's layout: mount paths, ports and names. Never a secret, and never another system's host,
    /// so a missing one fails at startup with the key's name.
    static var applicationDefaults: Self {
        .init(values: [
            "grpc.server.host": "0.0.0.0",
            "grpc.server.port": 50052,
            "grpc.server.hostname": "users",
            "grpc.server.internalCallers.createUser": .init(.stringArray(["auth-worker"]), isSecret: false),
            "tls.certificatePath": "/run/tls/cert.pem",
            "tls.privateKeyPath": "/run/tls/key.pem",
            "tls.trustRootsPath": "/run/tls/ca.pem",
            "jwt.publicKeyPath": "/run/jwt/public.pem",
            "postgres.port": 5432,
            "postgres.db": "harbor_users",
            "postgres.tls.trustRootsPath": "/run/tls/ca.pem",
            "postgres.owner.user": "users_owner",
            "postgres.owner.passwordPath": "/run/secrets/postgres-owner-password",
            "postgres.service.user": "users_service",
            "postgres.service.passwordPath": "/run/secrets/postgres-service-password",
            "postgres.internal.user": "users_internal",
            "postgres.internal.passwordPath": "/run/secrets/postgres-internal-password",
        ])
    }
}

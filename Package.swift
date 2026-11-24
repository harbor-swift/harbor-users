// swift-tools-version: 6.4

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .strictMemorySafety(),
]

let package = Package(
    name: "harbor-users",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "users", targets: ["Users"])
    ],
    dependencies: [
        .package(url: "file:///Users/zrahawi/Developer/microservices-example/harbor-core", from: "1.0.0"),
        .package(url: "file:///Users/zrahawi/Developer/microservices-example/harbor-protos", from: "1.0.0"),
        .package(url: "https://github.com/swift-microservices/swift-authentication.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-microservices/swift-authentication-grpc.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-microservices/swift-authentication-jwt.git", from: "1.1.0"),
        .package(url: "https://github.com/swift-microservices/swift-operation-context.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-microservices/swift-persistence.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-microservices/swift-persistence-postgres.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.8.2"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.1.7"),
        .package(url: "https://github.com/apple/swift-configuration.git", from: "1.5.0", traits: []),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.17.2"),
        .package(url: "https://github.com/apple/swift-nio-extras.git", from: "1.35.3"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.41.0", traits: []),
        .package(url: "https://github.com/grpc/grpc-swift-2.git", from: "2.4.4"),
        .package(url: "https://github.com/grpc/grpc-swift-extras.git", from: "2.2.2"),
        .package(url: "https://github.com/grpc/grpc-swift-nio-transport.git", from: "2.13.2"),
        .package(url: "https://github.com/hummingbird-project/postgres-migrations.git", from: "1.2.0"),
        .package(url: "https://github.com/swift-otel/swift-otel.git", from: "1.6.1", traits: ["OTLPGRPC"]),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.13.0"),
        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.33.3"),
    ],
    targets: [
        .target(
            name: "UsersCore",
            dependencies: [
                .product(name: "HarborAuthentication", package: "harbor-core"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Persistence", package: "swift-persistence"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "UsersPostgres",
            dependencies: [
                "UsersCore",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "PersistencePostgres", package: "swift-persistence-postgres"),
                .product(name: "PostgresMigrations", package: "postgres-migrations"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "UsersGRPC",
            dependencies: [
                "UsersCore",
                .product(name: "Authentication", package: "swift-authentication"),
                .product(name: "GRPCCore", package: "grpc-swift-2"),
                .product(name: "HarborAuthentication", package: "harbor-core"),
                .product(name: "OperationContext", package: "swift-operation-context"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "UsersProtos", package: "harbor-protos"),
            ],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "Users",
            dependencies: [
                "UsersCore",
                "UsersGRPC",
                "UsersPostgres",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AuthenticationGRPC", package: "swift-authentication-grpc"),
                .product(name: "AuthenticationJWT", package: "swift-authentication-jwt"),
                .product(name: "Configuration", package: "swift-configuration"),
                .product(name: "GRPCCore", package: "grpc-swift-2"),
                .product(name: "GRPCHealthService", package: "grpc-swift-extras"),
                .product(name: "GRPCNIOTransportHTTP2", package: "grpc-swift-nio-transport"),
                .product(name: "GRPCOTelTracingInterceptors", package: "grpc-swift-extras"),
                .product(name: "GRPCServiceLifecycle", package: "grpc-swift-extras"),
                .product(name: "HarborAuthentication", package: "harbor-core"),
                .product(name: "HarborPersistence", package: "harbor-core"),
                .product(name: "HarborTransport", package: "harbor-core"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIOCertificateReloading", package: "swift-nio-extras"),
                .product(name: "OTel", package: "swift-otel"),
                .product(name: "PersistencePostgres", package: "swift-persistence-postgres"),
                .product(name: "PostgresMigrations", package: "postgres-migrations"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "UnixSignals", package: "swift-service-lifecycle"),
                .product(name: "UsersProtos", package: "harbor-protos"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "UsersCoreTests",
            dependencies: [
                "UsersCore",
                .product(name: "HarborAuthentication", package: "harbor-core"),
                .product(name: "HarborTesting", package: "harbor-core"),
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "UsersGRPCTests",
            dependencies: [
                "UsersCore",
                "UsersGRPC",
                .product(name: "Authentication", package: "swift-authentication"),
                .product(name: "GRPCCore", package: "grpc-swift-2"),
                .product(name: "HarborAuthentication", package: "harbor-core"),
                .product(name: "OperationContext", package: "swift-operation-context"),
                .product(name: "UsersProtos", package: "harbor-protos"),
            ],
            swiftSettings: swiftSettings
        ),
    ],
    swiftLanguageModes: [.v6]
)

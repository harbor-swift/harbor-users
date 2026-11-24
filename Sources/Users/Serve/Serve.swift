import ArgumentParser
import AuthenticationGRPC
import AuthenticationJWT
import Configuration
import GRPCCore
import GRPCHealthService
import GRPCNIOTransportHTTP2
import GRPCOTelTracingInterceptors
import GRPCServiceLifecycle
import HarborAuthentication
import HarborPersistence
import HarborTransport
import Logging
import NIOCertificateReloading
import OTel
import PersistencePostgres
import PostgresNIO
import ServiceLifecycle
import UnixSignals
import UsersCore
import UsersGRPC
import UsersPostgres
import UsersProtos

struct Serve: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "serve",
        abstract: "Serve the users gRPC services"
    )

    func run() async throws {
        // MARK: - Configuration
        let config = ConfigReader(providers: [
            EnvironmentVariablesProvider(),
            InMemoryProvider.applicationDefaults,
        ])

        // MARK: - Logging
        let logLevel = config.string(forKey: "logLevel", as: Logger.Level.self, default: .info)
        let traceMetadataProvider = OTel.makeLoggingMetadataProvider()
        let metadataProvider = Logger.MetadataProvider.multiplex([.user, traceMetadataProvider])
        LoggingSystem.bootstrap(
            { label, metadataProvider in
                var handler = StreamLogHandler.standardOutput(label: label, metadataProvider: metadataProvider)
                handler.logLevel = logLevel
                return handler
            },
            metadataProvider: metadataProvider
        )
        let logger = Logger(label: "harbor-users")

        // MARK: - Observability
        var otelConfiguration = OTel.Configuration.default
        otelConfiguration.serviceName = "harbor-users"
        otelConfiguration.logs.enabled = false
        let observability = try OTel.bootstrap(configuration: otelConfiguration)

        // MARK: - Infrastructure
        let tlsConfig = config.scoped(to: "tls")
        var certificateReloaderConfiguration = try TimedCertificateReloader.Configuration(config: tlsConfig)
        certificateReloaderConfiguration.logger = logger
        certificateReloaderConfiguration.onCertificateLoadFailed = { failure in
            logger.warning(
                "Certificate reload failed: keeping the last good pair",
                metadata: ["error": "\(failure.error)"]
            )
        }
        let certificateReloader = try TimedCertificateReloader.makeReloaderValidatingSources(
            configuration: certificateReloaderConfiguration
        )

        let postgresConfig = config.scoped(to: "postgres")
        let servicePostgresConfiguration = try PostgresClient.Configuration(config: postgresConfig, role: "service")
        let postgresClient = PostgresClient(configuration: servicePostgresConfiguration, backgroundLogger: logger)
        let internalPostgresConfiguration = try PostgresClient.Configuration(config: postgresConfig, role: "internal")
        let internalPostgresClient = PostgresClient(
            configuration: internalPostgresConfiguration,
            backgroundLogger: logger
        )

        let jwtConfig = config.scoped(to: "jwt")
        let authenticator = try await JWTAuthenticator<UserIdentity>(config: jwtConfig)

        // MARK: - Composition
        // The caller's own user is read on the tenant database, where the policy confines each transaction to the
        // caller; Auth's worker creates users it names, on the internal one.
        let database = PostgresDatabase<PostgresUsersScope>(client: postgresClient, logger: logger)
        let internalDatabase = PostgresDatabase<PostgresUsersInternalScope>(
            client: internalPostgresClient,
            logger: logger
        )
        let getUserUseCase = GetUserUseCase(database: database, logger: logger)
        let createUserUseCase = CreateUserUseCase(database: internalDatabase, logger: logger)
        let userService = UserService(getUserUseCase: getUserUseCase)
        let userInternalService = UserInternalService(createUserUseCase: createUserUseCase)

        // MARK: - gRPC
        let serverConfig = config.scoped(to: "grpc.server")
        let serverHost = try serverConfig.requiredString(forKey: "host")
        let serverPort = try serverConfig.requiredInt(forKey: "port")
        let serverHostname = try serverConfig.requiredString(forKey: "hostname")
        let serverSecurity: HTTP2ServerTransport.Posix.TransportSecurity = try .mTLS(
            config: tlsConfig,
            certificateReloader: certificateReloader
        )
        let serverTransportConfig = HTTP2ServerTransport.Posix.Config(config: serverConfig)
        let serverTransport = HTTP2ServerTransport.Posix(
            address: .ipv4(host: serverHost, port: serverPort),
            transportSecurity: serverSecurity,
            config: serverTransportConfig
        )
        let internalCallersConfig = serverConfig.scoped(to: "internalCallers")
        let callers = try [MethodDescriptor: Set<String>](config: internalCallersConfig)
        let internalCallers = InternalCallerInterceptor(callers: callers, logger: logger)
        let serverTracing = ServerOTelTracingInterceptor(serverHostname: serverHostname, networkTransportMethod: "tcp")
        let bearerAuthentication = BearerAuthenticationInterceptor(authenticator: authenticator)
        let userSettings = UserSettingsInterceptor()
        let healthService = HealthService()
        healthService.provider.updateStatus(.serving, forService: "")
        let server = GRPCServer(
            transport: serverTransport,
            services: [userService, userInternalService, healthService],
            interceptorPipeline: [
                .apply(internalCallers, to: .all),
                .apply(
                    serverTracing,
                    to: .services([
                        Harbor_Users_V1_UserService.descriptor,
                        Harbor_Users_V1_UserInternalService.descriptor,
                    ])
                ),
                .apply(bearerAuthentication, to: .services([Harbor_Users_V1_UserService.descriptor])),
                .apply(userSettings, to: .services([Harbor_Users_V1_UserService.descriptor])),
            ]
        )

        // MARK: - Lifecycle
        let serviceGroup = ServiceGroup(
            services: [
                observability,
                certificateReloader,
                postgresClient,
                internalPostgresClient,
                server,
            ],
            gracefulShutdownSignals: [.sigterm, .sigint],
            logger: logger
        )
        logger.info("Serving", metadata: ["port": "\(serverPort)"])
        try await withLogger(logger) { _ in
            try await serviceGroup.run()
        }
    }
}

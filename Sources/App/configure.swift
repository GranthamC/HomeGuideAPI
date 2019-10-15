import FluentPostgreSQL
import Vapor
import Leaf
import Authentication

var adminName: String?
var adminPassword: String?


/// Called before your application initializes.
public func configure(
	_ config: inout Config,
	_ env: inout Environment,
	_ services: inout Services
) throws {
	
	
    try services.register(FluentPostgreSQLProvider())

	try services.register(LeafProvider())
	
	try services.register(AuthenticationProvider())
	
    let router = EngineRouter.default()
	
    try routes(router)
	
    services.register(router, as: Router.self)
    
	var middlewares = MiddlewareConfig()
	
	let corsConfiguration = CORSMiddleware.Configuration(
		allowedOrigin: .all,
		allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
		allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
	)
	
	let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
	
	middlewares.use(corsMiddleware)
	
    middlewares.use(ErrorMiddleware.self)
	
    services.register(middlewares)
	
    var databases = DatabasesConfig()
	
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
	
    let username = Environment.get("DATABASE_USER") ?? "vapor"
	
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
	
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
	
	adminName = Environment.get("MCH_ADMIN_USER")  ??  "vapor"
	
	adminPassword = Environment.get("MCH_ADMIN_PASSWORD")  ??  "password!"
	

    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        username: username,
        database: databaseName,
        password: password)
	
    let database = PostgreSQLDatabase(config: databaseConfig)
	
    databases.add(database: database, as: .psql)
	
    services.register(databases)
	
    // Configure migrations
	//
    var migrations = MigrationConfig()
	
	migrations.add(model: DbAdmin.self, database: .psql)
	
	migrations.add(model: Token.self, database: .psql)
	
	migrations.add(migration: AdminUser.self, database: .psql)

    services.register(migrations)
}

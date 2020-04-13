import FluentPostgreSQL
import Vapor
import Leaf
import Authentication


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
	
	/*
		let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
		
		let username = Environment.get("DATABASE_USER") ?? "vapor"
		
		let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
		
		let password = Environment.get("DATABASE_PASSWORD") ?? "password"

		let databaseConfig = PostgreSQLDatabaseConfig(
			hostname: hostname,
			username: username,
			database: databaseName,
			password: password)
	*/
		
		let dbName = Environment.get("POSTGRES_DB") ?? "vapor"

		let username = Environment.get("POSTGRES_USER") ?? "vapor"
		
		let password = Environment.get("POSTGRES_PASSWORD") ?? "password"

		let databaseConfig: PostgreSQLDatabaseConfig
		
		if let url = Environment.get("DATABASE_URL")
		{
			databaseConfig = PostgreSQLDatabaseConfig(url: url)!
		}
		else
		{
			let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
			
			let databaseName: String
			
			let databasePort: Int
			
			if env == .testing
			{
				databaseName = "vapor-test"
				if let testPort = Environment.get("DATABASE_PORT") {
					databasePort = Int(testPort) ?? 5433
				}
				else
				{
					databasePort = 5433
				}
			}
			else
			{
				databaseName = dbName
				databasePort = 5432
			}
			
			databaseConfig = PostgreSQLDatabaseConfig(
				hostname: hostname,
				port: databasePort,
				username: username,
				database: databaseName,
				password: password)
		}
		
    let database = PostgreSQLDatabase(config: databaseConfig)
	
    databases.add(database: database, as: .psql)
	
    services.register(databases)

    // Configure migrations
	//
    var migrations = MigrationConfig()
	
	migrations.add(model: DbAdmin.self, database: .psql)
	
	migrations.add(model: Token.self, database: .psql)
	
	migrations.add(model: HomeGuideGlobal.self, database: .psql)
	
	migrations.add(model: ChangeTokens.self, database: .psql)

	migrations.add(model: HomeImage.self, database: .psql)
	
	migrations.add(model: ModelImageNdx.self, database: .psql)
	
	migrations.add(model: HomeModel.self, database: .psql)
	
	migrations.add(model: Plant.self, database: .psql)
	
	migrations.add(model: ProductLine.self, database: .psql)
	
	migrations.add(model: Brand.self, database: .psql)
	
	migrations.add(model: HomeSet.self, database: .psql)
	
	migrations.add(model: HomeSetModel.self, database: .psql)
	
	migrations.add(model: HomeVenue.self, database: .psql)
	
	migrations.add(model: VenueModel.self, database: .psql)
	
	migrations.add(model: VenueModelImage.self, database: .psql)
	
	migrations.add(migration: AdminUser.self, database: .psql)

    services.register(migrations)
	
	
	// Add command line configuration service
	//
	var commandConfig = CommandConfig.default()

	commandConfig.useFluentCommands()

	services.register(commandConfig)
}

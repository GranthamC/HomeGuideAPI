import Foundation
import Vapor
import FluentPostgreSQL
import Authentication



final class DbAdmin: Codable
{
	typealias Database = PostgreSQLDatabase
	
	var id: UUID?
	
	var name: String
	var username: String
	var password: String
	
	var venueManager: Bool?
	var managedVenueID: Int32?
	
	var superUser: Bool?
	var adminUser: Bool?
	
	init(name: String, username: String, password: String) {
		self.name = name
		self.username = username
		self.password = password
		
		self.superUser = false
		self.adminUser = false
	}
	
	final class Public: Codable {
		var id: UUID?
		var name: String
		var username: String
		
		init(id: UUID?, name: String, userName: String) {
			
			self.id = id
			self.username = userName
			self.name = name
		}
	}
}

extension DbAdmin: PostgreSQLUUIDModel {}

extension DbAdmin: Migration
{
	static func prepare(on connection: PostgreSQLConnection)
		-> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
			builder.unique(on: \.username)
		}
	}
	
}

extension DbAdmin: Content {}

extension DbAdmin: Parameter {}

extension DbAdmin
{
	func convertToPublic() -> DbAdmin.Public
	{
		return DbAdmin.Public(id: id, name: name, userName: username)
	}
}


extension DbAdmin.Public: Content {}


extension Future where T: DbAdmin
{
	func convertToPublic() -> Future<DbAdmin.Public>
	{
		return self.map(to: DbAdmin.Public.self) { user in
			
			return user.convertToPublic()
		}
	}
}


extension DbAdmin: BasicAuthenticatable
{
	static let usernameKey: UsernameKey = \DbAdmin.username
	
	static let passwordKey: PasswordKey = \DbAdmin.password
}


extension DbAdmin: TokenAuthenticatable
{
	typealias TokenType = Token
}

struct AdminUser: Migration
{
	typealias Database = PostgreSQLDatabase
	
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		guard let adminName = Environment.get("HGD_ADMIN_USER") else
		{
			fatalError("Failed to load initial username!")
		}

		guard let adminPassword = Environment.get("HGD_ADMIN_PASSWORD") else
		{
			fatalError("Failed to load initial user password!")
		}
		
		guard let hashedPassword = try? BCrypt.hash(adminPassword) else
		{
			fatalError("Failed to create hash password: \(adminName)     password:\(adminPassword)")
		}
				
		let user = DbAdmin(name: "Admin", username: adminName, password: hashedPassword)
		
		user.superUser = true
		user.adminUser = true
		
		return user.save(on: connection).transform(to: ())
	}
	
	
	static func revert(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return .done(on: connection)
	}
}


import Foundation
import Vapor
import FluentPostgreSQL

final class VenueModel: Codable
{
	var id: UUID?
	
	var brandID: String
	var brandDescription: String
	
	var acronym: String?
	
	var changeToken: UInt32?

	init(name: String, idCode: String)
	{
		self.brandDescription = name
		self.brandID = idCode
	}
}


extension VenueModel: PostgreSQLUUIDModel {}

extension VenueModel: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
			//			builder.unique(on: \.plantName)
		}
	}
}

extension VenueModel: Content {}

extension VenueModel: Parameter {}

extension VenueModel
{

}




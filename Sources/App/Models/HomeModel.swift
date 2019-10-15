import Foundation
import Vapor
import FluentPostgreSQL

final class HomeModel: Codable
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


extension HomeModel: PostgreSQLUUIDModel {}

extension HomeModel: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
			//			builder.unique(on: \.plantName)
		}
	}
}

extension HomeModel: Content {}

extension HomeModel: Parameter {}

extension HomeModel
{

}



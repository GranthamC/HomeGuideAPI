import Foundation
import Vapor
import FluentPostgreSQL

final class Brand: Codable
{
	var id: UUID?
	
    var acronym: String?
    var brandID: Int32
    var brandName: String?
	
    var logoImageID: Int32?
	
	var websiteURL: String?

	var changeToken: Int32?

	init(brandID: Int32, brandName: String, acronym: String)
	{
		self.brandID = brandID
		self.brandName = brandName
		self.acronym = acronym
	}
}


extension Brand: PostgreSQLUUIDModel {}

extension Brand: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
//			builder.unique(on: \.plantName)
		}
	}
}

extension Brand: Content {}

extension Brand: Parameter {}

extension Brand
{

}





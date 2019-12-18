import Foundation
import Vapor
import FluentPostgreSQL

final class Plant: Codable
{
	var id: UUID?
	
    var plantID: Int32
    var plantName: String
    var plantNumber: Int16

    var logoImageID: Int32?
	
    var streetAddress: String?
	var city: String?
    var state: String?
    var postalCode: String?

	var websiteURL: String?
	
	var changeToken: Int32?


	init(plantID: Int32, plantName: String, plantNumber: Int16)
	{
		self.plantID = plantID
		self.plantName = plantName
		self.plantNumber = plantNumber
	}
}


extension Plant: PostgreSQLUUIDModel {}

extension Plant: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
//			builder.unique(on: \.modelNumber)
		}
	}
}

extension Plant: Content {}

extension Plant: Parameter {}

extension Plant
{

}







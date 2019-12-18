import Foundation
import Vapor
import FluentPostgreSQL

final class ProductLine: Codable
{
	var id: UUID?
	
	var lineID: Int32
	var lineDescription: String?
	
	var plantID: Int32
	var plantNumber: Int16
	
	var brandID: Int32?

    var logoImageID: Int32?

	var websiteURL: String?
	var isActive: Bool
	
	var changeToken: Int32?


	init(lineID: Int32, lineDescription: String, plantID: Int32, plantNumber: Int16)
	{
		self.lineID = lineID
		self.lineDescription = lineDescription
		self.plantID = plantID
		self.plantNumber = plantNumber
		
		self.isActive = true
	}
}


extension ProductLine: PostgreSQLUUIDModel {}

extension ProductLine: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
//			builder.unique(on: \.modelNumber)
		}
	}
}

extension ProductLine: Content {}

extension ProductLine: Parameter {}

extension ProductLine
{

}








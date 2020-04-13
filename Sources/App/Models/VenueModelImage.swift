import Foundation
import Vapor
import FluentPostgreSQL

final class VenueModelImage: Codable
{
	typealias Database = PostgreSQLDatabase
	
	var id: UUID?
	
    var caption: String?
    var imageID: Int32
    var imageTypeID: Int16?
    var venueModelID: Int32
    var venueModelImageID: Int32
    var roomID: Int16?
	
	var changeToken: Int32?


	init(venueModelID: Int32, imageID: Int32, venueModelImageID: Int32)
	{
		self.venueModelID = venueModelID
		self.imageID = imageID
		self.venueModelImageID = venueModelImageID
	}
}


extension VenueModelImage: PostgreSQLUUIDModel {}

extension VenueModelImage: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
//			builder.unique(on: \.modelNumber)
		}
	}
}

extension VenueModelImage: Content {}

extension VenueModelImage: Parameter {}

extension VenueModelImage
{

}







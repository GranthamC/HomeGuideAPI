import Foundation
import Vapor
import FluentPostgreSQL

final class VenueModel: Codable
{
	typealias Database = PostgreSQLDatabase
	
	var id: UUID?
	
	var venueModelID: Int32
	var venueID: Int32
	var modelID: Int32
	
    var arImageID: Int32?
	
	var exteriorImageID: Int32?
    var floorplanID: Int32?
    var heroImageID: Int32?
	
    var matterportTourURL: String?
	
    var quickLookFloorplanID: Int32?
    var quickLookFloorplanURL: String?

    var meshModelID: Int32?
    var meshModelURL: String?
	
	var isActive: Bool = true

	var changeToken: Int32?

	init(venueModelID: Int32, venueID: Int32, modelID: Int32)
	{
		self.venueModelID = venueModelID
		self.venueID = venueID
		self.modelID = modelID
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




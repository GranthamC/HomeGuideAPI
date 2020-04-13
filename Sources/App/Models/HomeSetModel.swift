import Foundation
import Vapor
import FluentPostgreSQL

final class HomeSetModel: Codable
{
	typealias Database = PostgreSQLDatabase
	
	var id: UUID?
	
	var homeSetModelID: Int32
	var homeSetID: Int32
	var venueModelID: Int32

    var arImageID: Int32?
	
	var exteriorImageID: Int32?
    var floorplanID: Int32?
    var heroImageID: Int32?
	
    var matterportTourURL: String?
	
    var quickLookFloorplanID: Int32?
    var quickLookFloorplanURL: String?

    var meshModelID: Int32?
    var meshModelURL: String?

	var changeToken: Int32?

	init(venueModelID: Int32, homeSetID: Int32, homeSetModelID: Int32)
	{
		self.venueModelID = venueModelID
		self.homeSetID = homeSetID
		self.homeSetModelID = homeSetModelID
	}
}


extension HomeSetModel: PostgreSQLUUIDModel {}

extension HomeSetModel: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
//			builder.unique(on: \.plantName)
		}
	}
}

extension HomeSetModel: Content {}

extension HomeSetModel: Parameter {}

extension HomeSetModel
{

}





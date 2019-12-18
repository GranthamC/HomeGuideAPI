import Foundation
import Vapor
import FluentPostgreSQL

final class HomeSet: Codable
{
	var id: UUID?
	
	var homeSetID: Int32

	var venueID: Int32
	
    var logoImageID: Int32?
	
	var setTitle: String?
	var setDescription: String?
	
	var orderByIndex: Bool?
	
	var homeSetBrochureURL: String?
	
	var useCategories: Bool?
	var useBrochure: Bool?
	var useFactoryTour: Bool?
	
	var isActive: Bool = true

	var changeToken: Int32?

	init(homeSetID: Int32, venueID: Int32)
	{
		self.homeSetID = homeSetID
		
		self.venueID = venueID
	}
}


extension HomeSet: PostgreSQLUUIDModel {}

extension HomeSet: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
//			builder.unique(on: \.venueID)
		}
	}
}

extension HomeSet: Content {}

extension HomeSet: Parameter {}

extension HomeSet
{

}





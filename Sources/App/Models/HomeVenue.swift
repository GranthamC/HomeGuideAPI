import Foundation
import Vapor
import FluentPostgreSQL

final class HomeVenue: Codable
{
	typealias Database = PostgreSQLDatabase
	
	var id: UUID?
	
	var venueID: Int32
	var venueName: String
	
    var logoImageID: Int32?
	
    var streetAddress: String?
	var city: String?
    var state: String?
    var postalCode: String?

	var websiteURL: String?
	
	var changeToken: Int32?

	init(venueName: String, venueID: Int32)
	{
		self.venueName = venueName
		
		self.venueID = venueID
	}
}


extension HomeVenue: PostgreSQLUUIDModel {}

extension HomeVenue: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
//			builder.unique(on: \.venueID)
		}
	}
}

extension HomeVenue: Content {}

extension HomeVenue: Parameter {}

extension HomeVenue
{
	var gpsLocation: Children<HomeVenue, GpsPoint> {
		
		return children(\.homeVenueID)
	}

}




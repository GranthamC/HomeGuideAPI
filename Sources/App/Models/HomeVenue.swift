import Foundation
import Vapor
import FluentPostgreSQL

final class HomeVenue: Codable
{
	var id: UUID?
	
	var venueID: String
	var venueName: String

	init(name: String, idCode: String?)
	{
		self.venueName = name
		
		if let venue = idCode
		{
			self.venueID = venue
		}
		else
		{
			self.venueID = self.id!.uuidString
		}
	}
}


extension HomeVenue: PostgreSQLUUIDModel {}

extension HomeVenue: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
			builder.unique(on: \.venueID)
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




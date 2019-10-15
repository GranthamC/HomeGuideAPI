import Foundation
import Vapor
import FluentPostgreSQL



// MARK: Image Asset Type Enum and labels
//
enum gpsPointType: Int32 {
	case isVenueLocation = 0
	case isModelLocation = 1
	case isRoutePoint = 2
	case isVenueBoundaryPoint = 3
}


final class GpsPoint: Codable
{
	var id: UUID?
	
	var pointID:  String?
	
	var homeVenueID: HomeVenue.ID?
	
	var venueModelID: VenueModel.ID?
	
	var isRoutePoint: Bool
	var isModelLocation: Bool
	var isVenueLocation: Bool
	
	var latitude: Double		// Positive values indicate latitudes north of the equator. Negative values south
	
	var longitude: Double		// Measurements are relative to the zero meridian, with positive values extending
								// east of the meridian and negative values extending west of the meridian.
	
	var timeStamp: TimeInterval
	
	var horizontalAccuracy: Double?

	
	init(latitude: Double, longitude: Double, timeInterval: TimeInterval, pointType: Int32, idCode: String?)
	{
		self.latitude = latitude
		self.longitude = longitude
		self.timeStamp = timeInterval
		
		if let ptID = idCode
		{
			self.pointID = ptID
		}
		else
		{
			self.pointID = self.id!.uuidString
		}

		self.isRoutePoint = false
		self.isModelLocation = false
		self.isVenueLocation = false
		
		// Now set the point type
		//
		switch pointType
		{
		case gpsPointType.isVenueLocation.rawValue:
			self.isVenueLocation = true
			
		case gpsPointType.isModelLocation.rawValue:
			self.isModelLocation = true
			
		case gpsPointType.isRoutePoint.rawValue:
			self.isRoutePoint = true
			
		default:
			break
		}
		
	}
}


extension GpsPoint: PostgreSQLUUIDModel {}

extension GpsPoint: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
			builder.reference(from: \.venueModelID, to: \VenueModel.id)

			builder.reference(from: \.homeVenueID, to: \HomeVenue.id)
			
			builder.unique(on: \.pointID)
		}
	}
}

extension GpsPoint: Content {}

extension GpsPoint: Parameter {}

extension GpsPoint
{
	
	var homeVenue: Parent<GpsPoint, HomeVenue> {
		
		return parent(\.venueModelID)!
	}

}






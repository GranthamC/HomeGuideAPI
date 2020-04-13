import Foundation
import Vapor
import FluentPostgreSQL

final class HomeModel: Codable
{
	typealias Database = PostgreSQLDatabase
	
	var id: UUID?
	
    var modelID: Int32
    var modelNumber: String
    var modelDescription: String

    var lineID: Int16?
    var brandID: Int32?

    var arImageID: Int32?
	
    var baths: Float?
    var beds: Int16?

	var exteriorImageID: Int32?
    var floorplanID: Int32?
    var heroImageID: Int32?
	
    var isModular: Bool?
    var isMultiSection: Bool?
    var isWebEnabled: Bool?
	
    var matterportTourURL: String?
	var websiteURL:String?
	
    var quickLookFloorplanID: Int32?
    var quickLookFloorplanURL: String?

    var meshModelID: Int32?
    var meshModelURL: String?
	
    var minSqFt: Int16?
    var maxSqFt: Int16?
    var modelWidth: Int16?
    var modelLength: Int16?
	
    var highPrice: Double?
    var lowPrice: Double?
	
    var twoYearsSales: Int16?
    var wholesalePrice: Double?
	
	var changeToken: Int32?


	init(modelID: Int32, modelNumber: String, modelDescription: String)
	{
		self.modelNumber = modelNumber
		self.modelID = modelID
		self.modelDescription = modelDescription
	}
}


extension HomeModel: PostgreSQLUUIDModel {}

extension HomeModel: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
			builder.unique(on: \.modelNumber)
		}
	}
}

extension HomeModel: Content {}

extension HomeModel: Parameter {}

extension HomeModel
{

}



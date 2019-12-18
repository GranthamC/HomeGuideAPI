import Foundation
import Vapor
import FluentPostgreSQL

final class HomeGuideGlobal: Codable
{
	var id: UUID?
	
    var nextARActionID: Int32?
    var nextARImageID: Int32?
    var nextARModelID: Int32?
    var nextHomeSetID: Int32?
    var nextModelID: Int32?
    var nextModelImageID: Int32?
    var nextModelImageNdxID: Int32?
    var nextOptionCategoryID: Int32?
    var nextOptionGroupID: Int32?
    var nextOptionID: Int32?
    var nextOptionImageID: Int32?
    var nextQuickLookFloorplanID: Int32?
    var nextQuickLookNodeID: Int32?


	init()
	{
		
	}
}


extension HomeGuideGlobal: PostgreSQLUUIDModel {}

extension HomeGuideGlobal: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
//			builder.unique(on: \.modelNumber)
		}
	}
}

extension HomeGuideGlobal: Content {}

extension HomeGuideGlobal: Parameter {}

extension HomeGuideGlobal
{

}




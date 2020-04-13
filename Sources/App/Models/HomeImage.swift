import Foundation
import Vapor
import FluentPostgreSQL
import Authentication


final class HomeImage: Codable
{
	typealias Database = PostgreSQLDatabase
	
	var id: UUID?
	
    var cloudPath: String
    var imageID: Int32
    var localPath: String?
    var serverID: Int16
	
	var changeToken: Int32?


	init(cloudPath: String, imageID: Int32, serverID: Int16)
	{
		self.cloudPath = cloudPath
		self.imageID = imageID
		self.serverID = serverID
	}
}


extension HomeImage: PostgreSQLUUIDModel {}

extension HomeImage: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
//			builder.unique(on: \.modelNumber)
		}
	}
}

extension HomeImage: Content {}

extension HomeImage: Parameter {}

extension HomeImage
{

}





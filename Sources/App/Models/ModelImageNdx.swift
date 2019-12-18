import Foundation
import Vapor
import FluentPostgreSQL

final class ModelImageNdx: Codable
{
	var id: UUID?
	
    var caption: String?
    var imageID: Int32
    var imageTypeID: Int16?
    var modelID: Int32
    var modelImageID: Int32
    var roomID: Int16?
	
	var changeToken: Int32?


	init(modelID: Int32, imageID: Int32, modelImageID: Int32)
	{
		self.modelID = modelID
		self.imageID = imageID
		self.modelImageID = modelImageID
	}
}


extension ModelImageNdx: PostgreSQLUUIDModel {}

extension ModelImageNdx: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
//			builder.unique(on: \.modelNumber)
		}
	}
}

extension ModelImageNdx: Content {}

extension ModelImageNdx: Parameter {}

extension ModelImageNdx
{

}






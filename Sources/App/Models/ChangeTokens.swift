import Foundation
import Vapor
import FluentPostgreSQL

final class ChangeTokens: Codable
{
	typealias Database = PostgreSQLDatabase
	
	var id: UUID?
	
    var appID: String
	var appTokensID: Int32
	
	var lastUpdatedBy: String?
	
    var brandChangeToken: Int32 = 0
    var homeImageChangeToken: Int32 = 0
    var homeModelChangeToken: Int32 = 0
    var homeSetCategoryChangeToken: Int32 = 0
    var homeSetChangeToken: Int32 = 0
    var homeSetModelChangeToken: Int32 = 0
    var homeVenueChangeToken: Int32 = 0
    var lineOptionChangeToken: Int32 = 0
    var modelImageChangeToken: Int32 = 0
    var modelOptionChangeToken: Int32 = 0
    var modelOptionImageChangeToken: Int32 = 0
    var optionGroupChangeToken: Int32 = 0
    var optionImageChangeToken: Int32 = 0
    var optionImageNdxChangeToken: Int32 = 0
    var optionItemChangeToken: Int32 = 0
    var plantChangeToken: Int32 = 0
    var productLineChangeToken: Int32 = 0
    var quickLookFloorplanChangeToken: Int32 = 0
    var quickLookNodeChangeToken: Int32 = 0
    var venueModelChangeToken: Int32 = 0
	
    var changeToken: Int32 = 0

	init(appID: String, appTokensID: Int32, lastUpdatedBy: String?)
	{
		self.appID = appID
		self.appTokensID = appTokensID
		
		if let updatedBy = lastUpdatedBy
		{
			self.lastUpdatedBy = updatedBy
		}
	}
}


extension ChangeTokens: PostgreSQLUUIDModel {}

extension ChangeTokens: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			
			try addProperties(to: builder)
			
			builder.unique(on: \.appID)
		}
	}
}

extension ChangeTokens: Content {}

extension ChangeTokens: Parameter {}

extension ChangeTokens
{

}






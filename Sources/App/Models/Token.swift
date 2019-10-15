//
//  Token.swift
//  App
//
//  Created by Craig Grantham on 10/14/19.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
	var id: UUID?
	var token: String
	var userID: DbAdmin.ID
	
	init(token: String, userID: DbAdmin.ID)
	{
		self.token = token
		self.userID = userID
	}
}

extension Token: PostgreSQLUUIDModel {}

extension Token: Migration
{
	static func prepare(on connection: PostgreSQLConnection) -> Future<Void>
	{
		return Database.create(self, on: connection) { builder in
			try addProperties(to: builder)
			builder.reference(from: \.userID, to: \DbAdmin.id)
		}
	}
}

extension Token: Content {}


extension Token
{
	static func generate(for user: DbAdmin) throws -> Token
	{
		let random = try CryptoRandom().generateData(count: 16)
		
		return try Token(token: random.base64EncodedString(), userID: user.requireID())
	}
}


extension Token: Authentication.Token
{
	static let userIDKey: UserIDKey = \Token.userID
	
	typealias UserType = DbAdmin
}


extension Token: BearerAuthenticatable
{
	static let tokenKey: TokenKey = \Token.token
}


import Vapor
import Fluent
import Crypto

struct DbAdminController: RouteCollection
{
	func boot(router: Router) throws {
		
		let usersRoute = router.grouped("api", "user")
		
		//		usersRoute.post(DbAdmin.self, use: createHandler)
		
		//		usersRoute.get(use: getAllHandler)
		
		//		usersRoute.get(DbAdmin.parameter, use: getHandler)
		
		//		usersRoute.put(DbAdmin.parameter, use: updateHandler)
		
		//		usersRoute.delete(DbAdmin.parameter, use: deleteHandler)
		
		//		usersRoute.get("search", use: searchHandler)
		
		//		usersRoute.get("first", use: getFirstHandler)
		
		//		usersRoute.get("sorted", use: sortedHandler)
		
		let basicAuthMiddleware = DbAdmin.basicAuthMiddleware(using: BCryptDigest())
		
		let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
		
		basicAuthGroup.post("login", use: loginHandler)
		
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
		
		tokenAuthGroup.get("logout", use: logoutHandler)
		
		tokenAuthGroup.post(DbAdmin.self, use: createHandler)
		
		tokenAuthGroup.delete(DbAdmin.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(DbAdmin.parameter, use: updateHandler)
		
		tokenAuthGroup.get(DbAdmin.parameter, use: getHandler)
		
		tokenAuthGroup.get("search", use: searchHandler)
		
		tokenAuthGroup.get(use: getAllHandler)
		
	}
	
	
	func createHandler(_ req: Request, user: DbAdmin) throws -> Future<DbAdmin.Public> {
		
		user.password = try BCrypt.hash(user.password)
		
		return user.save(on: req).convertToPublic()
	}
	
	
	func loginHandler(_ req: Request) throws -> Future<Token>
	{
		let user = try req.requireAuthenticated(DbAdmin.self)
		
		// If old token, delete and generate a new one and return it
		//
		_ = try Token.query(on: req).filter(\Token.userID, .equal, user.requireID()).delete().flatMap { _ -> EventLoopFuture<Token> in
			
			let token = try Token.generate(for: user)
			
			return token.save(on: req)
		}
		
		let token = try Token.generate(for: user)
		
		return token.save(on: req)
	}
	
	func logoutHandler(_ req: Request) throws -> Future<HTTPResponse> {
		
		let user = try req.requireAuthenticated(DbAdmin.self)
		
		return try Token
			.query(on: req)
			.filter(\Token.userID, .equal, user.requireID())
			.delete()
			.transform(to: HTTPResponse(status: .ok))
	}
	
	
	func getAllHandler(_ req: Request) throws -> Future<[DbAdmin.Public]> {
		
		return DbAdmin.query(on: req).decode(data: DbAdmin.Public.self).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<DbAdmin.Public>
	{
		return try req.parameters.next(DbAdmin.self).convertToPublic()
	}
	
	// Update passed user with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<DbAdmin> {
		
		return try flatMap(to: DbAdmin.self, req.parameters.next(DbAdmin.self), req.content.decode(DbAdmin.self)) { user, updatedUser in
			
			user.name = updatedUser.name
			
			user.username = updatedUser.username
			
			user.password = try BCrypt.hash(updatedUser.password)
			
			return user.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(DbAdmin.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	func searchHandler(_ req: Request) throws -> Future<[DbAdmin.Public]>
	{
		guard let searchTerm = req.query[String.self, at: "param"] else {
			throw Abort(.badRequest)
		}
		
		return DbAdmin.query(on: req).group(.or) { or in
			or.filter(\.name == searchTerm)
			or.filter(\.username == searchTerm)
			}.decode(data: DbAdmin.Public.self).all()
	}
	
	
	func getFirstHandler(_ req: Request) throws -> Future<DbAdmin>
	{
		return DbAdmin.query(on: req)
			.first()
			
			.map(to: DbAdmin.self) { homebuilder in
				guard let homebuilder = homebuilder else {
					throw Abort(.notFound)
				}
				
				return homebuilder
		}
	}
	
	
	func sortedHandler(_ req: Request) throws -> Future<[DbAdmin]>
	{
		return DbAdmin.query(on: req).sort(\.name, .ascending).all()
	}
}





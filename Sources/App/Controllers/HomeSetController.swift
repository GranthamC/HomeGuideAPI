
import Vapor
import Fluent
import Authentication


struct HomeSetController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let homeSetsRoute = router.grouped("api", "home-set")
		
		homeSetsRoute.get(use: getAllHandler)
		
		homeSetsRoute.get(HomeSet.parameter, use: getHandler)
		
		homeSetsRoute.get("homesetid", Int32.parameter, use: getHomeSetHandler)
		
		homeSetsRoute.get("homeset-models", Int32.parameter, use: getHomeSetsForVenueHandler)

		homeSetsRoute.get("search", use: searchHandler)

		
		// Add-in authentication for creating and updating
		//
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = homeSetsRoute.grouped(
			tokenAuthMiddleware,
			guardAuthMiddleware)
		
		tokenAuthGroup.post(HomeSet.self, use: createHandler)
		
		tokenAuthGroup.delete(HomeSet.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(HomeSet.parameter, use: updateHandler)
	}
	
	
	func createHandler(	_ req: Request, homeSet: HomeSet) throws -> Future<HomeSet>
	{
		
		return homeSet.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[HomeSet]>
	{
		return HomeSet.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<HomeSet>
	{
		return try req.parameters.next(HomeSet.self)
	}
	
	
	// Update passed product home option Item with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<HomeSet> {
		
		return try flatMap(
			to: HomeSet.self,
			req.parameters.next(HomeSet.self),
			req.content.decode(HomeSet.self)
		) {
			homeSet, updatedHomeSet in
			
			homeSet.homeSetID = updatedHomeSet.homeSetID
			homeSet.venueID = updatedHomeSet.venueID
			
			homeSet.logoImageID = updatedHomeSet.logoImageID
			
			homeSet.setTitle = updatedHomeSet.setTitle
			homeSet.setDescription = updatedHomeSet.setDescription
			
			homeSet.orderByIndex = updatedHomeSet.orderByIndex
			homeSet.homeSetBrochureURL = updatedHomeSet.homeSetBrochureURL
			
			homeSet.useCategories = updatedHomeSet.useCategories
			homeSet.useBrochure = updatedHomeSet.useBrochure
			homeSet.useFactoryTour = updatedHomeSet.useFactoryTour

			homeSet.isActive = updatedHomeSet.isActive
			
			homeSet.changeToken = updatedHomeSet.changeToken

			return homeSet.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(HomeSet.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	func searchHandler(_ req: Request) throws -> Future<[HomeSet]>
	{
		guard let searchTerm = req.query[String.self, at: "title"] else {
			throw Abort(.badRequest)
		}
		
		return HomeSet.query(on: req).group(.or) { or in
			or.filter(\.setTitle == searchTerm)
			}.all()
	}
	
	
	// Find HomeSet for the passed homeSetID
	//
	func getHomeSetHandler(_ req: Request) throws -> Future<HomeSet>
	{
		let homeSetID = try req.parameters.next(Int32.self)
		
		return HomeSet.query(on: req).group(.or) { or in
			or.filter(\.homeSetID == homeSetID)
		}.first().map(to: HomeSet.self) { homeSetRecord -> HomeSet in
			
			if let homeSet = homeSetRecord
			{
				return homeSet
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	// Find all models associated with the passed homeSetID
	//
	func getHomeSetsForVenueHandler(_ req: Request) throws -> Future<[HomeSetModel]>
	{
		let homeSetID = try req.parameters.next(Int32.self)
		
		return HomeSetModel.query(on: req).group(.or) { or in
			or.filter(\.homeSetID == homeSetID)
		}.all()

	}

}












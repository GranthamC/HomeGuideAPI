
import Vapor
import Fluent
import Authentication


struct HomeVenueController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let homeVenuesRoute = router.grouped("api", "home-venue")
		
		homeVenuesRoute.get(use: getAllHandler)
		
		homeVenuesRoute.get(HomeVenue.parameter, use: getHandler)
		
		homeVenuesRoute.get("venueid", Int32.parameter, use: getHomeVenueHandler)
		
		homeVenuesRoute.get("venue-models", Int32.parameter, use: getVenueModelsHandler)

		homeVenuesRoute.get("search", use: searchHandler)

		
		// Add-in authentication for creating and updating
		//
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = homeVenuesRoute.grouped(
			tokenAuthMiddleware,
			guardAuthMiddleware)
		
		tokenAuthGroup.post(HomeVenue.self, use: createHandler)
		
		tokenAuthGroup.delete(HomeVenue.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(HomeVenue.parameter, use: updateHandler)
	}
	
	
	func createHandler(	_ req: Request, venue: HomeVenue) throws -> Future<HomeVenue>
	{
		
		return venue.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[HomeVenue]>
	{
		return HomeVenue.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<HomeVenue>
	{
		return try req.parameters.next(HomeVenue.self)
	}
	
	
	// Update passed product home option Item with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<HomeVenue> {
		
		return try flatMap(
			to: HomeVenue.self,
			req.parameters.next(HomeVenue.self),
			req.content.decode(HomeVenue.self)
		) {
			venue, updatedHomeVenue in
			
			venue.venueID = updatedHomeVenue.venueID
			venue.venueName = updatedHomeVenue.venueName
			
			venue.logoImageID = updatedHomeVenue.logoImageID
			
			venue.streetAddress = updatedHomeVenue.streetAddress
			venue.city = updatedHomeVenue.city
			venue.state = updatedHomeVenue.state
			venue.postalCode = updatedHomeVenue.postalCode
			
			venue.websiteURL = updatedHomeVenue.websiteURL
			
			venue.changeToken = updatedHomeVenue.changeToken

			return venue.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(HomeVenue.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	func searchHandler(_ req: Request) throws -> Future<[HomeVenue]>
	{
		guard let searchTerm = req.query[String.self, at: "name"] else {
			throw Abort(.badRequest)
		}
		
		return HomeVenue.query(on: req).group(.or) { or in
			or.filter(\.venueName == searchTerm)
			}.all()
	}
	
	
	// Find HomeVenue for the passed venueID
	//
	func getHomeVenueHandler(_ req: Request) throws -> Future<HomeVenue>
	{
		let venueID = try req.parameters.next(Int32.self)
		
		return HomeVenue.query(on: req).group(.or) { or in
			or.filter(\.venueID == venueID)
		}.first().map(to: HomeVenue.self) { venueRecord -> HomeVenue in
			
			if let venue = venueRecord
			{
				return venue
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	// Find all models associated with the passed venueID
	//
	func getVenueModelsHandler(_ req: Request) throws -> Future<[VenueModel]>
	{
		let venueID = try req.parameters.next(Int32.self)
		
		return VenueModel.query(on: req).group(.or) { or in
			or.filter(\.venueID == venueID)
		}.all()

	}

}











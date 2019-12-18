
import Vapor
import Fluent
import Authentication


struct HomeImageController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let homeImagesRoute = router.grouped("api", "home-image")
		
		homeImagesRoute.get(use: getAllHandler)
		
		homeImagesRoute.get(HomeImage.parameter, use: getHandler)
		
		homeImagesRoute.get("imageid", Int32.parameter, use: getImageIDHandler)
		
		homeImagesRoute.get("search", use: searchHandler)

		
		// Add-in authentication for creating and updating
		//
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = homeImagesRoute.grouped(
			tokenAuthMiddleware,
			guardAuthMiddleware)
		
		tokenAuthGroup.post(HomeImage.self, use: createHandler)
		
		tokenAuthGroup.delete(HomeImage.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(HomeImage.parameter, use: updateHandler)

	}
	
	
	func createHandler(	_ req: Request, imageAsset: HomeImage) throws -> Future<HomeImage>
	{
		
		return imageAsset.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[HomeImage]>
	{
		return HomeImage.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<HomeImage>
	{
		return try req.parameters.next(HomeImage.self)
	}
	
	
	// Update passed product home option Item with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<HomeImage> {
		
		return try flatMap(
			to: HomeImage.self,
			req.parameters.next(HomeImage.self),
			req.content.decode(HomeImage.self)
		) {
			homeImage, updatedHomeImage in
			
			homeImage.cloudPath = updatedHomeImage.cloudPath
			homeImage.imageID = updatedHomeImage.imageID
			homeImage.serverID = updatedHomeImage.serverID
			
			homeImage.changeToken = updatedHomeImage.changeToken

			return homeImage.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(HomeImage.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	func searchHandler(_ req: Request) throws -> Future<[HomeImage]>
	{
		guard let searchTerm = req.query[String.self, at: "id"] else {
			throw Abort(.badRequest)
		}
		
		var imageID: Int32 = 0
		
		if let idNum: Int32 = Int32(searchTerm)
		{
			imageID = idNum
		}
		else
		{
			throw Abort(.badRequest)
		}
		
		return HomeImage.query(on: req).group(.or) { or in
			or.filter(\.imageID == imageID)
			}.all()
	}
	
	
	func getImageIDHandler(_ req: Request) throws -> Future<HomeImage>
	{
		let imageID = try req.parameters.next(Int32.self)
		
		return HomeImage.query(on: req).group(.or) { or in
			or.filter(\.imageID == imageID)
		}.first().map(to: HomeImage.self) { image -> HomeImage in
			
			if let homeImage = image
			{
				return homeImage
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}

	
}








import Vapor
import Fluent
import Authentication


struct VenueModelImageController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let homeImageNdxsRoute = router.grouped("api", "venue-model-image")
		
		homeImageNdxsRoute.get(use: getAllHandler)
		
		homeImageNdxsRoute.get(VenueModelImage.parameter, use: getHandler)
		
		homeImageNdxsRoute.get("imageNdxid", Int32.parameter, use: getImageNdxIDHandler)
		
		homeImageNdxsRoute.get("imageid", Int32.parameter, use: getImageIDHandler)
		
		homeImageNdxsRoute.get("modelid", Int32.parameter, use: getModelIDHandler)

		homeImageNdxsRoute.get("search", use: searchHandler)

		
		// Add-in authentication for creating and updating
		//
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = homeImageNdxsRoute.grouped(
			tokenAuthMiddleware,
			guardAuthMiddleware)
		
		tokenAuthGroup.post(VenueModelImage.self, use: createHandler)
		
		tokenAuthGroup.delete(VenueModelImage.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(VenueModelImage.parameter, use: updateHandler)
	}
	
	
	func createHandler(	_ req: Request, imageAsset: VenueModelImage) throws -> Future<VenueModelImage>
	{
		
		return imageAsset.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[VenueModelImage]>
	{
		return VenueModelImage.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<VenueModelImage>
	{
		return try req.parameters.next(VenueModelImage.self)
	}
	
	
	// Update passed product home option Item with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<VenueModelImage> {
		
		return try flatMap(
			to: VenueModelImage.self,
			req.parameters.next(VenueModelImage.self),
			req.content.decode(VenueModelImage.self)
		) {
			imageAsset, updatedHomeImageNdx in
			
			imageAsset.caption = updatedHomeImageNdx.caption
			imageAsset.imageID = updatedHomeImageNdx.imageID
			imageAsset.venueModelID = updatedHomeImageNdx.venueModelID
			
			imageAsset.imageTypeID = updatedHomeImageNdx.imageTypeID
			imageAsset.venueModelImageID = updatedHomeImageNdx.venueModelImageID
			imageAsset.roomID = updatedHomeImageNdx.roomID

			imageAsset.changeToken = updatedHomeImageNdx.changeToken

			return imageAsset.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(VenueModelImage.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	func searchHandler(_ req: Request) throws -> Future<[VenueModelImage]>
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
		
		return VenueModelImage.query(on: req).group(.or) { or in
			or.filter(\.imageID == imageID)
				or.filter(\.venueModelID == imageID)
				or.filter(\.venueModelImageID == imageID)
			}.all()
	}
	
	
	func getImageNdxIDHandler(_ req: Request) throws -> Future<VenueModelImage>
	{
		let imageNdxID = try req.parameters.next(Int32.self)
		
		return VenueModelImage.query(on: req).group(.or) { or in
			or.filter(\.venueModelImageID == imageNdxID)
		}.first().map(to: VenueModelImage.self) { image -> VenueModelImage in
			
			if let venueModelImage = image
			{
				return venueModelImage
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	// Find all places a home image with imageID is used
	//
	func getImageIDHandler(_ req: Request) throws -> Future<[VenueModelImage]>
	{
		let imageID = try req.parameters.next(Int32.self)
		
		return VenueModelImage.query(on: req).group(.or) { or in
			or.filter(\.imageID == imageID)
		}.all()

	}
	
	
	// Find all images for the passed venueModelID
	//
	func getModelIDHandler(_ req: Request) throws -> Future<[VenueModelImage]>
	{
		let modelID = try req.parameters.next(Int32.self)
		
		return VenueModelImage.query(on: req).group(.or) { or in
			or.filter(\.venueModelID == modelID)
		}.all()
	}
	
}









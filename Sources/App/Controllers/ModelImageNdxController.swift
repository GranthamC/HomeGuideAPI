
import Vapor
import Fluent
import Authentication


struct ModelImageNdxController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let homeImageNdxsRoute = router.grouped("api", "model-imagendx")
		
		homeImageNdxsRoute.get(use: getAllHandler)
		
		homeImageNdxsRoute.get(ModelImageNdx.parameter, use: getHandler)
		
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
		
		tokenAuthGroup.post(ModelImageNdx.self, use: createHandler)
		
		tokenAuthGroup.delete(ModelImageNdx.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(ModelImageNdx.parameter, use: updateHandler)
	}
	
	
	func createHandler(	_ req: Request, imageAsset: ModelImageNdx) throws -> Future<ModelImageNdx>
	{
		
		return imageAsset.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[ModelImageNdx]>
	{
		return ModelImageNdx.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<ModelImageNdx>
	{
		return try req.parameters.next(ModelImageNdx.self)
	}
	
	
	// Update passed product home option Item with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<ModelImageNdx> {
		
		return try flatMap(
			to: ModelImageNdx.self,
			req.parameters.next(ModelImageNdx.self),
			req.content.decode(ModelImageNdx.self)
		) {
			imageAsset, updatedHomeImageNdx in
			
			imageAsset.caption = updatedHomeImageNdx.caption
			imageAsset.imageID = updatedHomeImageNdx.imageID
			imageAsset.modelID = updatedHomeImageNdx.modelID
			
			imageAsset.imageTypeID = updatedHomeImageNdx.imageTypeID
			imageAsset.modelImageID = updatedHomeImageNdx.modelImageID
			imageAsset.roomID = updatedHomeImageNdx.roomID
			
			imageAsset.changeToken = updatedHomeImageNdx.changeToken

			return imageAsset.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(ModelImageNdx.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	func searchHandler(_ req: Request) throws -> Future<[ModelImageNdx]>
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
		
		return ModelImageNdx.query(on: req).group(.or) { or in
			or.filter(\.imageID == imageID)
				or.filter(\.modelID == imageID)
				or.filter(\.modelImageID == imageID)
			}.all()
	}
	
	
	func getImageNdxIDHandler(_ req: Request) throws -> Future<ModelImageNdx>
	{
		let imageNdxID = try req.parameters.next(Int32.self)
		
		return ModelImageNdx.query(on: req).group(.or) { or in
			or.filter(\.modelImageID == imageNdxID)
		}.first().map(to: ModelImageNdx.self) { image -> ModelImageNdx in
			
			if let homeImageNdx = image
			{
				return homeImageNdx
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	// Find all places a home image with imageID is used
	//
	func getImageIDHandler(_ req: Request) throws -> Future<[ModelImageNdx]>
	{
		let imageID = try req.parameters.next(Int32.self)
		
		return ModelImageNdx.query(on: req).group(.or) { or in
			or.filter(\.imageID == imageID)
		}.all()

	}
	
	
	// Find all images for the passed modelID
	//
	func getModelIDHandler(_ req: Request) throws -> Future<[ModelImageNdx]>
	{
		let modelID = try req.parameters.next(Int32.self)
		
		return ModelImageNdx.query(on: req).group(.or) { or in
			or.filter(\.modelID == modelID)
		}.all()

	}
}








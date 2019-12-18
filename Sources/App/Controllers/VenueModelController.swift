
import Vapor
import Fluent
import Authentication


struct VenueModelController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let venueModelsRoute = router.grouped("api", "venue-model")
		
		venueModelsRoute.get(use: getAllHandler)
		
		venueModelsRoute.get(VenueModel.parameter, use: getHandler)
		
		venueModelsRoute.get("venueModelid", Int32.parameter, use: getVenueModelHandler)
		
		venueModelsRoute.get("venueid", Int32.parameter, use: getVenueModelsHandler)

		venueModelsRoute.get("modelid", Int32.parameter, use: getVenuesForModelHandler)

		venueModelsRoute.get("search", use: searchHandler)

		
		// Add-in authentication for creating and updating
		//
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = venueModelsRoute.grouped(
			tokenAuthMiddleware,
			guardAuthMiddleware)
		
		tokenAuthGroup.post(VenueModel.self, use: createHandler)
		
		tokenAuthGroup.delete(VenueModel.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(VenueModel.parameter, use: updateHandler)
	}
	
	
	func createHandler(	_ req: Request, venueModel: VenueModel) throws -> Future<VenueModel>
	{
		
		return venueModel.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[VenueModel]>
	{
		return VenueModel.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<VenueModel>
	{
		return try req.parameters.next(VenueModel.self)
	}
	
	
	// Update passed product home option Item with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<VenueModel> {
		
		return try flatMap(
			to: VenueModel.self,
			req.parameters.next(VenueModel.self),
			req.content.decode(VenueModel.self)
		) {
			venueModel, updatedVenueModel in
			
			venueModel.venueModelID = updatedVenueModel.venueModelID
			venueModel.venueID = updatedVenueModel.venueID
			venueModel.modelID = updatedVenueModel.modelID
			
			venueModel.arImageID = updatedVenueModel.arImageID
			venueModel.exteriorImageID = updatedVenueModel.exteriorImageID
			venueModel.floorplanID = updatedVenueModel.floorplanID
			
			venueModel.matterportTourURL = updatedVenueModel.matterportTourURL
			venueModel.quickLookFloorplanID = updatedVenueModel.quickLookFloorplanID
			venueModel.quickLookFloorplanURL = updatedVenueModel.quickLookFloorplanURL
			
			venueModel.meshModelID = updatedVenueModel.meshModelID
			venueModel.meshModelURL = updatedVenueModel.meshModelURL
			venueModel.changeToken = updatedVenueModel.changeToken

			return venueModel.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(VenueModel.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	func searchHandler(_ req: Request) throws -> Future<[VenueModel]>
	{
		guard let searchTerm = req.query[String.self, at: "id"] else {
			throw Abort(.badRequest)
		}
		
		var venueModelID: Int32 = 0
		
		if let idNum: Int32 = Int32(searchTerm)
		{
			venueModelID = idNum
		}
		else
		{
			throw Abort(.badRequest)
		}
		
		return VenueModel.query(on: req).group(.or) { or in
			or.filter(\.venueModelID == venueModelID)
		}.all()
	}
	
	
	func getVenueModelHandler(_ req: Request) throws -> Future<VenueModel>
	{
		let venueModelID = try req.parameters.next(Int32.self)
		
		return VenueModel.query(on: req).group(.or) { or in
			or.filter(\.venueModelID == venueModelID)
		}.first().map(to: VenueModel.self) { venueModelRecord -> VenueModel in
			
			if let venueModel = venueModelRecord
			{
				return venueModel
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	// Find all venues a home with modelID is used
	//
	func getVenuesForModelHandler(_ req: Request) throws -> Future<[VenueModel]>
	{
		let modelID = try req.parameters.next(Int32.self)
		
		return VenueModel.query(on: req).group(.or) { or in
			or.filter(\.modelID == modelID)
		}.all()

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









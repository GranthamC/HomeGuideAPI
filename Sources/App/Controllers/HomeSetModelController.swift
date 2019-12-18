
import Vapor
import Fluent
import Authentication


struct HomeSetModelController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let homeSetModelsRoute = router.grouped("api", "homeset-model")
		
		homeSetModelsRoute.get(use: getAllHandler)
		
		homeSetModelsRoute.get(HomeSetModel.parameter, use: getHandler)
		
		homeSetModelsRoute.get("homesetmodelid", Int32.parameter, use: getHomeSetModelHandler)
		
		homeSetModelsRoute.get("homesetid", Int32.parameter, use: getHomeSetModelsHandler)

		homeSetModelsRoute.get("modelid", Int32.parameter, use: getHomeSetModelsHandler)

		homeSetModelsRoute.get("search", use: searchHandler)

		
		// Add-in authentication for creating and updating
		//
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = homeSetModelsRoute.grouped(
			tokenAuthMiddleware,
			guardAuthMiddleware)
		
		tokenAuthGroup.post(HomeSetModel.self, use: createHandler)
		
		tokenAuthGroup.delete(HomeSetModel.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(HomeSetModel.parameter, use: updateHandler)
	}
	
	
	func createHandler(	_ req: Request, homeSetModel: HomeSetModel) throws -> Future<HomeSetModel>
	{
		
		return homeSetModel.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[HomeSetModel]>
	{
		return HomeSetModel.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<HomeSetModel>
	{
		return try req.parameters.next(HomeSetModel.self)
	}
	
	
	// Update passed product home option Item with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<HomeSetModel> {
		
		return try flatMap(
			to: HomeSetModel.self,
			req.parameters.next(HomeSetModel.self),
			req.content.decode(HomeSetModel.self)
		) {
			homeSetModel, updatedHomeSetModel in
			
			homeSetModel.homeSetModelID = updatedHomeSetModel.homeSetModelID
			homeSetModel.homeSetID = updatedHomeSetModel.homeSetID
			homeSetModel.venueModelID = updatedHomeSetModel.venueModelID
			
			homeSetModel.arImageID = updatedHomeSetModel.arImageID
			homeSetModel.exteriorImageID = updatedHomeSetModel.exteriorImageID
			homeSetModel.floorplanID = updatedHomeSetModel.floorplanID
			
			homeSetModel.matterportTourURL = updatedHomeSetModel.matterportTourURL
			homeSetModel.quickLookFloorplanID = updatedHomeSetModel.quickLookFloorplanID
			homeSetModel.quickLookFloorplanURL = updatedHomeSetModel.quickLookFloorplanURL
			
			homeSetModel.meshModelID = updatedHomeSetModel.meshModelID
			homeSetModel.meshModelURL = updatedHomeSetModel.meshModelURL
			homeSetModel.changeToken = updatedHomeSetModel.changeToken

			return homeSetModel.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(HomeSetModel.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	func searchHandler(_ req: Request) throws -> Future<[HomeSetModel]>
	{
		guard let searchTerm = req.query[String.self, at: "id"] else {
			throw Abort(.badRequest)
		}
		
		var homeSetModelID: Int32 = 0
		
		if let idNum: Int32 = Int32(searchTerm)
		{
			homeSetModelID = idNum
		}
		else
		{
			throw Abort(.badRequest)
		}
		
		return HomeSetModel.query(on: req).group(.or) { or in
			or.filter(\.homeSetModelID == homeSetModelID)
		}.all()
	}
	
	
	func getHomeSetModelHandler(_ req: Request) throws -> Future<HomeSetModel>
	{
		let homeSetModelID = try req.parameters.next(Int32.self)
		
		return HomeSetModel.query(on: req).group(.or) { or in
			or.filter(\.homeSetModelID == homeSetModelID)
		}.first().map(to: HomeSetModel.self) { homeSetModelRecord -> HomeSetModel in
			
			if let homeSetModel = homeSetModelRecord
			{
				return homeSetModel
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	// Find all homeSets a home with modelID is used
	//
	func getHomeSetsForModelHandler(_ req: Request) throws -> Future<[HomeSetModel]>
	{
		let venueModelID = try req.parameters.next(Int32.self)
		
		return HomeSetModel.query(on: req).group(.or) { or in
			or.filter(\.venueModelID == venueModelID)
		}.all()

	}
	
	
	// Find all models associated with the passed homeSetID
	//
	func getHomeSetModelsHandler(_ req: Request) throws -> Future<[HomeSetModel]>
	{
		let homeSetID = try req.parameters.next(Int32.self)
		
		return HomeSetModel.query(on: req).group(.or) { or in
			or.filter(\.homeSetID == homeSetID)
		}.all()

	}
}










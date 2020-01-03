
import Vapor
import Fluent
import Authentication


struct HomeModelController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let homeModelsRoute = router.grouped("api", "home-model")
		
		homeModelsRoute.get(use: getAllHandler)
		
		homeModelsRoute.get(HomeModel.parameter, use: getHandler)
		
		homeModelsRoute.get("modelnumber", String.parameter, use: getModelNumberHandler)
		
		homeModelsRoute.get("modelid", Int32.parameter, use: getModelIDHandler)
		
		homeModelsRoute.get("lineid", Int32.parameter, use: getLineIDHandler)

		homeModelsRoute.get("search", use: searchHandler)

		
		// Add-in authentication for creating and updating
		//
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = homeModelsRoute.grouped(
			tokenAuthMiddleware,
			guardAuthMiddleware)
		
		tokenAuthGroup.post(HomeModel.self, use: createHandler)
		
		tokenAuthGroup.delete(HomeModel.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(HomeModel.parameter, use: updateHandler)
	}
	
	
	func createHandler(	_ req: Request, imageAsset: HomeModel) throws -> Future<HomeModel>
	{
		
		return imageAsset.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[HomeModel]>
	{
		return HomeModel.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<HomeModel>
	{
		return try req.parameters.next(HomeModel.self)
	}
	
	
	// Update passed product home option Item with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<HomeModel> {
		
		return try flatMap(
			to: HomeModel.self,
			req.parameters.next(HomeModel.self),
			req.content.decode(HomeModel.self)
		) {
			homeModel, updatedHomeModel in
			
			homeModel.modelID = updatedHomeModel.modelID
			homeModel.modelNumber = updatedHomeModel.modelNumber
			homeModel.modelDescription = updatedHomeModel.modelDescription
			homeModel.lineID = updatedHomeModel.lineID
			homeModel.brandID = updatedHomeModel.brandID

			homeModel.baths = updatedHomeModel.baths
			homeModel.beds = updatedHomeModel.beds
			homeModel.minSqFt = updatedHomeModel.minSqFt
			homeModel.maxSqFt = updatedHomeModel.maxSqFt
			homeModel.modelWidth = updatedHomeModel.modelWidth
			homeModel.modelLength = updatedHomeModel.modelLength
			
			homeModel.exteriorImageID = updatedHomeModel.exteriorImageID
			homeModel.floorplanID = updatedHomeModel.floorplanID
			homeModel.heroImageID = updatedHomeModel.heroImageID
			
			homeModel.isModular = updatedHomeModel.isModular
			homeModel.isMultiSection = updatedHomeModel.isMultiSection
			homeModel.isWebEnabled = updatedHomeModel.isWebEnabled
			
			homeModel.matterportTourURL = updatedHomeModel.matterportTourURL
			homeModel.websiteURL = updatedHomeModel.websiteURL
			
			homeModel.arImageID = updatedHomeModel.arImageID
			homeModel.meshModelID = updatedHomeModel.meshModelID
			homeModel.meshModelURL = updatedHomeModel.meshModelURL

			homeModel.quickLookFloorplanID = updatedHomeModel.quickLookFloorplanID
			homeModel.quickLookFloorplanURL = updatedHomeModel.quickLookFloorplanURL
			
			homeModel.highPrice = updatedHomeModel.highPrice
			homeModel.lowPrice = updatedHomeModel.lowPrice
			homeModel.wholesalePrice = updatedHomeModel.wholesalePrice
			
			homeModel.twoYearsSales = updatedHomeModel.twoYearsSales
			
			homeModel.changeToken = updatedHomeModel.changeToken

			return homeModel.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(HomeModel.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	func searchHandler(_ req: Request) throws -> Future<[HomeModel]>
	{
		guard let searchTerm = req.query[String.self, at: "id"] else {
			throw Abort(.badRequest)
		}
		
		var parmID: Int32 = 0
		
		if let idNum: Int32 = Int32(searchTerm)
		{
			parmID = idNum
		}
		else
		{
			throw Abort(.badRequest)
		}
		
		return HomeModel.query(on: req).group(.or) { or in
			or.filter(\.lineID == Int16(parmID))
				or.filter(\.modelID == parmID)
			}.all()
	}
	
	
	func getModelNumberHandler(_ req: Request) throws -> Future<HomeModel>
	{
		let modelNumber = try req.parameters.next(String.self)
		
		return HomeModel.query(on: req).group(.or) { or in
			or.filter(\.modelNumber == modelNumber)
		}.first().map(to: HomeModel.self) { model -> HomeModel in
			
			if let homeModel = model
			{
				return homeModel
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	// Find all places a home image with imageID is used
	//
	func getModelIDHandler(_ req: Request) throws -> Future<HomeModel>
	{
		let modelID = try req.parameters.next(Int32.self)
		
		return HomeModel.query(on: req).group(.or) { or in
			or.filter(\.modelID == modelID)
		}.first().map(to: HomeModel.self) { model -> HomeModel in
			
			if let homeModel = model
			{
				return homeModel
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	// Find all models for the passed lineID
	//
	func getLineIDHandler(_ req: Request) throws -> Future<[HomeModel]>
	{
		let lineID = try req.parameters.next(Int16.self)
		
		return HomeModel.query(on: req).group(.or) { or in
			or.filter(\.lineID == lineID)
		}.all()
	}
}









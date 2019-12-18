
import Vapor
import Fluent
import Authentication


struct PlantController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let plantsRoute = router.grouped("api", "plant")
		
		plantsRoute.get(use: getAllHandler)
		
		plantsRoute.get(Plant.parameter, use: getHandler)
		
		plantsRoute.get("plantnumber", Int16.parameter, use: getPlantNumberHandler)
		
		plantsRoute.get("plantid", Int32.parameter, use: getPlantIDHandler)

		plantsRoute.get("search", use: searchHandler)

		
		// Add-in authentication for creating and updating
		//
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = plantsRoute.grouped(
			tokenAuthMiddleware,
			guardAuthMiddleware)
		
		tokenAuthGroup.post(Plant.self, use: createHandler)
		
		tokenAuthGroup.delete(Plant.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(Plant.parameter, use: updateHandler)
	}
	
	
	func createHandler(	_ req: Request, plant: Plant) throws -> Future<Plant>
	{
		
		return plant.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[Plant]>
	{
		return Plant.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<Plant>
	{
		return try req.parameters.next(Plant.self)
	}
	
	
	// Update passed product home option Item with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<Plant> {
		
		return try flatMap(
			to: Plant.self,
			req.parameters.next(Plant.self),
			req.content.decode(Plant.self)
		) {
			plant, updatedPlant in
			
			plant.plantID = updatedPlant.plantID
			plant.plantName = updatedPlant.plantName
			plant.plantNumber = updatedPlant.plantNumber
			
			plant.logoImageID = updatedPlant.logoImageID
			
			plant.streetAddress = updatedPlant.streetAddress
			plant.city = updatedPlant.city
			plant.state = updatedPlant.state
			plant.postalCode = updatedPlant.postalCode
			
			plant.websiteURL = updatedPlant.websiteURL
			plant.changeToken = updatedPlant.changeToken

			return plant.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(Plant.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	func searchHandler(_ req: Request) throws -> Future<[Plant]>
	{
		guard let searchTerm = req.query[String.self, at: "name"] else {
			throw Abort(.badRequest)
		}
		
		return Plant.query(on: req).group(.or) { or in
			or.filter(\.plantName == searchTerm)
			}.all()
	}
	
	
	func getPlantNumberHandler(_ req: Request) throws -> Future<Plant>
	{
		let plantNumber = try req.parameters.next(Int16.self)
		
		return Plant.query(on: req).group(.or) { or in
			or.filter(\.plantNumber == plantNumber)
		}.first().map(to: Plant.self) { plantRecord -> Plant in
			
			if let plant = plantRecord
			{
				return plant
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	// Find all places a home image with imageID is used
	//
	func getPlantIDHandler(_ req: Request) throws -> Future<Plant>
	{
		let plantID = try req.parameters.next(Int32.self)
		
		return Plant.query(on: req).group(.or) { or in
			or.filter(\.plantID == plantID)
		}.first().map(to: Plant.self) { plantRecord -> Plant in
			
			if let plant = plantRecord
			{
				return plant
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}

}










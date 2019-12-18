
import Vapor
import Fluent
import Authentication


struct ProductLineController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let productLinesRoute = router.grouped("api", "line")
		
		productLinesRoute.get(use: getAllHandler)
		
		productLinesRoute.get(ProductLine.parameter, use: getHandler)
		
		productLinesRoute.get("plant-lines", Int16.parameter, use: getPlantLinesHandler)
		
		productLinesRoute.get("lineid", Int32.parameter, use: getLineIDHandler)

		productLinesRoute.get("search", use: searchHandler)

		
		// Add-in authentication for creating and updating
		//
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = productLinesRoute.grouped(
			tokenAuthMiddleware,
			guardAuthMiddleware)
		
		tokenAuthGroup.post(ProductLine.self, use: createHandler)
		
		tokenAuthGroup.delete(ProductLine.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(ProductLine.parameter, use: updateHandler)
	}
	
	
	func createHandler(	_ req: Request, plant: ProductLine) throws -> Future<ProductLine>
	{
		
		return plant.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[ProductLine]>
	{
		return ProductLine.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<ProductLine>
	{
		return try req.parameters.next(ProductLine.self)
	}
	
	
	// Update passed product home option Item with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<ProductLine> {
		
		return try flatMap(
			to: ProductLine.self,
			req.parameters.next(ProductLine.self),
			req.content.decode(ProductLine.self)
		) {
			productLine, updatedProductLine in
			
			productLine.lineID = updatedProductLine.lineID
			productLine.lineDescription = updatedProductLine.lineDescription
			
			productLine.plantID = updatedProductLine.plantID
			productLine.plantNumber = updatedProductLine.plantNumber
			
			productLine.brandID = updatedProductLine.brandID

			productLine.logoImageID = updatedProductLine.logoImageID
			
			productLine.isActive = updatedProductLine.isActive
			productLine.websiteURL = updatedProductLine.websiteURL
			productLine.changeToken = updatedProductLine.changeToken

			return productLine.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(ProductLine.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	func searchHandler(_ req: Request) throws -> Future<[ProductLine]>
	{
		guard let searchTerm = req.query[String.self, at: "name"] else {
			throw Abort(.badRequest)
		}
		
		return ProductLine.query(on: req).group(.or) { or in
			or.filter(\.lineDescription == searchTerm)
			}.all()
	}
	
	
	func getLineIDHandler(_ req: Request) throws -> Future<ProductLine>
	{
		let productLineID = try req.parameters.next(Int32.self)
		
		return ProductLine.query(on: req).group(.or) { or in
			or.filter(\.lineID == productLineID)
		}.first().map(to: ProductLine.self) { productLineRecord -> ProductLine in
			
			if let productLine = productLineRecord
			{
				return productLine
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	// Find all places a home image with imageID is used
	//
	func getPlantLinesHandler(_ req: Request) throws -> Future<[ProductLine]>
	{
		let plantNumber = try req.parameters.next(Int16.self)
		
		return ProductLine.query(on: req).group(.or) { or in
			or.filter(\.plantNumber == plantNumber)
		}.all()
	}

}











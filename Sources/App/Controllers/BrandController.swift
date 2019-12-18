
import Vapor
import Fluent
import Authentication


struct BrandController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let brandsRoute = router.grouped("api", "brand")
		
		brandsRoute.get(use: getAllHandler)
		
		brandsRoute.get(Brand.parameter, use: getHandler)
		
		brandsRoute.get("brandid", Int32.parameter, use: getBrandIDHandler)

		brandsRoute.get("search", use: searchHandler)

		
		// Add-in authentication for creating and updating
		//
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = brandsRoute.grouped(
			tokenAuthMiddleware,
			guardAuthMiddleware)
		
		tokenAuthGroup.post(Brand.self, use: createHandler)
		
		tokenAuthGroup.delete(Brand.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(Brand.parameter, use: updateHandler)
	}
	
	
	func createHandler(	_ req: Request, plant: Brand) throws -> Future<Brand>
	{
		
		return plant.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[Brand]>
	{
		return Brand.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<Brand>
	{
		return try req.parameters.next(Brand.self)
	}
	
	
	// Update passed product home option Item with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<Brand> {
		
		return try flatMap(
			to: Brand.self,
			req.parameters.next(Brand.self),
			req.content.decode(Brand.self)
		) {
			productLine, updatedBrand in
			
			productLine.brandID = updatedBrand.brandID
			productLine.acronym = updatedBrand.acronym
			productLine.brandName = updatedBrand.brandName

			productLine.logoImageID = updatedBrand.logoImageID
			
			productLine.websiteURL = updatedBrand.websiteURL
			productLine.changeToken = updatedBrand.changeToken

			return productLine.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(Brand.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	func searchHandler(_ req: Request) throws -> Future<[Brand]>
	{
		guard let searchTerm = req.query[String.self, at: "name"] else {
			throw Abort(.badRequest)
		}
		
		return Brand.query(on: req).group(.or) { or in
			or.filter(\.brandName == searchTerm)
			}.all()
	}
	
	
	func getBrandIDHandler(_ req: Request) throws -> Future<Brand>
	{
		let brandID = try req.parameters.next(Int32.self)
		
		return Brand.query(on: req).group(.or) { or in
			or.filter(\.brandID == brandID)
		}.first().map(to: Brand.self) { productLineRecord -> Brand in
			
			if let brand = productLineRecord
			{
				return brand
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}

}













import Vapor
import Fluent
import Authentication


struct HomeGuideGlobalController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let homeGuideGlobalsRoute = router.grouped("api", "global-ids")
		
		homeGuideGlobalsRoute.get(use: getAllHandler)
		
		homeGuideGlobalsRoute.get(HomeGuideGlobal.parameter, use: getHandler)

		
		// Add-in authentication for creating and updating
		//
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = homeGuideGlobalsRoute.grouped(
			tokenAuthMiddleware,
			guardAuthMiddleware)
		
		tokenAuthGroup.post(HomeGuideGlobal.self, use: createHandler)
		
		tokenAuthGroup.delete(HomeGuideGlobal.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(HomeGuideGlobal.parameter, use: updateHandler)
		
		tokenAuthGroup.get(HomeGuideGlobal.parameter, "next-home-image-id", use: getNextHomeImageID)
		
		tokenAuthGroup.get(HomeGuideGlobal.parameter, "next-model-imagendx-id", use: getNextModelImageNdxID)
		
		tokenAuthGroup.get(HomeGuideGlobal.parameter, "next-model-id", use: getNextModelID)
		
		tokenAuthGroup.get(HomeGuideGlobal.parameter, "next-option-image-id", use: getNextOptionImageID)

	}
	
	
	func createHandler(	_ req: Request, imageAsset: HomeGuideGlobal) throws -> Future<HomeGuideGlobal>
	{
		
		return imageAsset.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[HomeGuideGlobal]>
	{
		return HomeGuideGlobal.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<HomeGuideGlobal>
	{
		return try req.parameters.next(HomeGuideGlobal.self)
	}
	
	
	func getNextHomeImageID(_ req: Request) throws -> Future<Int32>
	{
		let globalIDs = try req.parameters.next(HomeGuideGlobal.self)
		
		return globalIDs.map(to: Int32.self) { hgGlobalDefs -> Int32 in
			
			if let nextID = hgGlobalDefs.nextModelImageID
			{
				hgGlobalDefs.nextModelImageID! += 1
				
				_ = hgGlobalDefs.save(on: req)
				
				return nextID
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	func getNextModelImageNdxID(_ req: Request) throws -> Future<Int32>
	{
		let globalIDs = try req.parameters.next(HomeGuideGlobal.self)
		
		return globalIDs.map(to: Int32.self) { hgGlobalDefs -> Int32 in
			
			if let nextID = hgGlobalDefs.nextModelImageNdxID
			{
				hgGlobalDefs.nextModelImageNdxID! += 1
				
				_ = hgGlobalDefs.save(on: req)
				
				return nextID
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	func getNextModelID(_ req: Request) throws -> Future<Int32>
	{
		let globalIDs = try req.parameters.next(HomeGuideGlobal.self)
		
		return globalIDs.map(to: Int32.self) { hgGlobalDefs -> Int32 in
			
			if let nextID = hgGlobalDefs.nextModelID
			{
				hgGlobalDefs.nextModelID! += 1
				
				_ = hgGlobalDefs.save(on: req)
				
				return nextID
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}
	
	
	func getNextOptionImageID(_ req: Request) throws -> Future<Int32>
	{
		let globalIDs = try req.parameters.next(HomeGuideGlobal.self)
		
		return globalIDs.map(to: Int32.self) { hgGlobalDefs -> Int32 in
			
			if let nextID = hgGlobalDefs.nextOptionImageID
			{
				hgGlobalDefs.nextOptionImageID! += 1
				
				_ = hgGlobalDefs.save(on: req)
				
				return nextID
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}

	
	
	// Update passed product home option Item with parameters
	//
	func updateHandler(_ req: Request) throws -> Future<HomeGuideGlobal> {
		
		return try flatMap(
			to: HomeGuideGlobal.self,
			req.parameters.next(HomeGuideGlobal.self),
			req.content.decode(HomeGuideGlobal.self)
		) {
			imageAsset, updatedHomeGuideGlobal in
			
			imageAsset.nextARActionID = updatedHomeGuideGlobal.nextARActionID
			imageAsset.nextARImageID = updatedHomeGuideGlobal.nextARImageID
			imageAsset.nextARModelID = updatedHomeGuideGlobal.nextARModelID
			
			imageAsset.nextHomeSetID = updatedHomeGuideGlobal.nextHomeSetID
			imageAsset.nextModelID = updatedHomeGuideGlobal.nextModelID
			imageAsset.nextModelImageID = updatedHomeGuideGlobal.nextModelImageID
			
			imageAsset.nextModelImageNdxID = updatedHomeGuideGlobal.nextModelImageNdxID
			imageAsset.nextOptionCategoryID = updatedHomeGuideGlobal.nextOptionCategoryID
			imageAsset.nextOptionGroupID = updatedHomeGuideGlobal.nextOptionGroupID
			
			imageAsset.nextOptionID = updatedHomeGuideGlobal.nextOptionID
			imageAsset.nextOptionImageID = updatedHomeGuideGlobal.nextOptionImageID
			imageAsset.nextQuickLookFloorplanID = updatedHomeGuideGlobal.nextQuickLookFloorplanID
			
			imageAsset.nextQuickLookNodeID = updatedHomeGuideGlobal.nextQuickLookNodeID

			return imageAsset.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(HomeGuideGlobal.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
}








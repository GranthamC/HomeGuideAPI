
import Vapor
import Fluent
import Authentication


struct ChangeTokensController: RouteCollection
{
	
	func boot(router: Router) throws {
		
		let changeTokensRoute = router.grouped("api", "change-tokens")
		
		changeTokensRoute.get(use: getAllHandler)
		
		changeTokensRoute.get(ChangeTokens.parameter, use: getHandler)
		
		changeTokensRoute.get("app-tokensid", Int32.parameter, use: getTokensWithIDHandler)
		
		changeTokensRoute.get("appid", String.parameter, use: getFromAppIDHandler)

		
		// Add-in authentication for creating and updating
		//
		let tokenAuthMiddleware = DbAdmin.tokenAuthMiddleware()
		let guardAuthMiddleware = DbAdmin.guardAuthMiddleware()
		
		let tokenAuthGroup = changeTokensRoute.grouped(
			tokenAuthMiddleware,
			guardAuthMiddleware)
		
		tokenAuthGroup.post(ChangeTokens.self, use: createHandler)
		
		tokenAuthGroup.delete(ChangeTokens.parameter, use: deleteHandler)
		
		tokenAuthGroup.put(ChangeTokens.parameter, use: updateHandler)
		
		tokenAuthGroup.get(ChangeTokens.parameter, "home-image", use: getNextHomeImageToken)
		
		tokenAuthGroup.get(ChangeTokens.parameter, "model-imagendx", use: getNextModelImageNdxToken)
		
		tokenAuthGroup.get(ChangeTokens.parameter, "home-model", use: getNextHomeModelToken)
		
		tokenAuthGroup.get(ChangeTokens.parameter, "option-image", use: getNextOptionImageToken)
		
		tokenAuthGroup.get(ChangeTokens.parameter, "app", use: getNextTokensChangeToken)
		
		tokenAuthGroup.get(ChangeTokens.parameter, "plant", use: getNextPlantsChangeToken)
		
		tokenAuthGroup.get(ChangeTokens.parameter, "line", use: getNextLinesChangeToken)
		
		tokenAuthGroup.get(ChangeTokens.parameter, "venue", use: getNextVenuesChangeToken)
		
		tokenAuthGroup.get(ChangeTokens.parameter, "venue-model", use: getNextVenueModelsChangeToken)
		
		tokenAuthGroup.get(ChangeTokens.parameter, "homeset", use: getNextHomeSetsChangeToken)
		
		tokenAuthGroup.get(ChangeTokens.parameter, "homeset-model", use: getNextHomeSetModelsChangeToken)
		
		tokenAuthGroup.get(ChangeTokens.parameter, "change-token", use: getNextChangeTokenChangeToken)

	}
	
	
	func createHandler(	_ req: Request, changeTokens: ChangeTokens) throws -> Future<ChangeTokens>
	{
		
		return changeTokens.save(on: req)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[ChangeTokens]>
	{
		return ChangeTokens.query(on: req).all()
	}
	
	
	func getHandler(_ req: Request) throws -> Future<ChangeTokens>
	{
		return try req.parameters.next(ChangeTokens.self)
	}
	
	
	func getFromAppIDHandler(_ req: Request) throws -> Future<ChangeTokens>
	{
		let appID = try req.parameters.next(String.self)
		
		return ChangeTokens.query(on: req).group(.or) { or in
			or.filter(\.appID == appID)
		}.first().map(to: ChangeTokens.self) { tokens -> ChangeTokens in
			
			if let changeTokens = tokens
			{
				return changeTokens
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}

	
	func getNextChangeTokenChangeToken(_ req: Request) throws -> Future<Int32>
	{
		let changeTokens = try req.parameters.next(ChangeTokens.self)
		
		return changeTokens.map(to: Int32.self) { tokens -> Int32 in
			
			tokens.changeToken += 1
			
			let nextToken = tokens.changeToken
			
			_ = tokens.save(on: req)
			
			return nextToken
		}
	}

	
	func getNextHomeSetModelsChangeToken(_ req: Request) throws -> Future<Int32>
	{
		let changeTokens = try req.parameters.next(ChangeTokens.self)
		
		return changeTokens.map(to: Int32.self) { tokens -> Int32 in
			
			tokens.homeSetModelChangeToken += 1
			
			let nextToken = tokens.homeSetModelChangeToken
			
			_ = tokens.save(on: req)
			
			return nextToken
		}
	}

	
	func getNextHomeSetsChangeToken(_ req: Request) throws -> Future<Int32>
	{
		let changeTokens = try req.parameters.next(ChangeTokens.self)
		
		return changeTokens.map(to: Int32.self) { tokens -> Int32 in
			
			tokens.homeSetChangeToken += 1
			
			let nextToken = tokens.homeSetChangeToken
			
			_ = tokens.save(on: req)
			
			return nextToken
		}
	}

	
	func getNextVenueModelsChangeToken(_ req: Request) throws -> Future<Int32>
	{
		let changeTokens = try req.parameters.next(ChangeTokens.self)
		
		return changeTokens.map(to: Int32.self) { tokens -> Int32 in
			
			tokens.venueModelChangeToken += 1
			
			let nextToken = tokens.venueModelChangeToken
			
			_ = tokens.save(on: req)
			
			return nextToken
		}
	}
	
	
	func getNextVenuesChangeToken(_ req: Request) throws -> Future<Int32>
	{
		let changeTokens = try req.parameters.next(ChangeTokens.self)
		
		return changeTokens.map(to: Int32.self) { tokens -> Int32 in
			
			tokens.homeVenueChangeToken += 1
			
			let nextToken = tokens.homeVenueChangeToken
			
			_ = tokens.save(on: req)
			
			return nextToken
		}
	}

	
	func getNextLinesChangeToken(_ req: Request) throws -> Future<Int32>
	{
		let changeTokens = try req.parameters.next(ChangeTokens.self)
		
		return changeTokens.map(to: Int32.self) { tokens -> Int32 in
			
			tokens.productLineChangeToken += 1
			
			let nextToken = tokens.productLineChangeToken
			
			_ = tokens.save(on: req)
			
			return nextToken
		}
	}

	
	func getNextPlantsChangeToken(_ req: Request) throws -> Future<Int32>
	{
		let changeTokens = try req.parameters.next(ChangeTokens.self)
		
		return changeTokens.map(to: Int32.self) { tokens -> Int32 in
			
			tokens.plantChangeToken += 1
			
			let nextToken = tokens.plantChangeToken
			
			_ = tokens.save(on: req)
			
			return nextToken
		}
	}

	
	func getNextHomeImageToken(_ req: Request) throws -> Future<Int32>
	{
		let changeTokens = try req.parameters.next(ChangeTokens.self)
		
		return changeTokens.map(to: Int32.self) { tokens -> Int32 in
			
			tokens.homeImageChangeToken += 1
			
			let nextToken = tokens.homeImageChangeToken
			
			_ = tokens.save(on: req)
			
			return nextToken
		}
	}
	
	
	func getNextModelImageNdxToken(_ req: Request) throws -> Future<Int32>
	{
		let changeTokens = try req.parameters.next(ChangeTokens.self)
		
		return changeTokens.map(to: Int32.self) { tokens -> Int32 in
			
			tokens.modelImageChangeToken += 1
			
			let nextToken = tokens.modelImageChangeToken
			
			_ = tokens.save(on: req)
			
			return nextToken
		}
	}
	
	
	func getNextHomeModelToken(_ req: Request) throws -> Future<Int32>
	{
		let changeTokens = try req.parameters.next(ChangeTokens.self)
		
		return changeTokens.map(to: Int32.self) { tokens -> Int32 in
			
			tokens.homeModelChangeToken += 1
			
			let nextToken = tokens.homeModelChangeToken
			
			_ = tokens.save(on: req)
			
			return nextToken
		}
	}
	
	
	func getNextOptionImageToken(_ req: Request) throws -> Future<Int32>
	{
		let changeTokens = try req.parameters.next(ChangeTokens.self)
		
		return changeTokens.map(to: Int32.self) { tokens -> Int32 in
			
			tokens.optionImageChangeToken += 1
			
			let nextToken = tokens.optionImageChangeToken
			
			_ = tokens.save(on: req)
			
			return nextToken
		}
	}
	
	
	func getNextTokensChangeToken(_ req: Request) throws -> Future<Int32>
	{
		let changeTokens = try req.parameters.next(ChangeTokens.self)
		
		return changeTokens.map(to: Int32.self) { tokens -> Int32 in
			
			tokens.changeToken += 1
			
			let nextToken = tokens.changeToken
			
			_ = tokens.save(on: req)
			
			return nextToken
		}
	}

	
	
	// Update the record to show who last touched it
	//
	func updateHandler(_ req: Request) throws -> Future<ChangeTokens> {
		
		return try flatMap(
			to: ChangeTokens.self,
			req.parameters.next(ChangeTokens.self),
			req.content.decode(ChangeTokens.self)
		) {
			changeTokens, updatedChangeTokens in
			
			changeTokens.appID = updatedChangeTokens.appID
			changeTokens.appTokensID = updatedChangeTokens.appTokensID
			
			changeTokens.brandChangeToken = updatedChangeTokens.brandChangeToken
			changeTokens.homeImageChangeToken = updatedChangeTokens.homeImageChangeToken
			changeTokens.homeModelChangeToken = updatedChangeTokens.homeModelChangeToken
			changeTokens.homeSetCategoryChangeToken = updatedChangeTokens.homeSetCategoryChangeToken
			
			changeTokens.homeSetChangeToken = updatedChangeTokens.homeSetChangeToken
			changeTokens.homeSetModelChangeToken = updatedChangeTokens.homeSetModelChangeToken
			changeTokens.homeVenueChangeToken = updatedChangeTokens.homeVenueChangeToken
			
			changeTokens.lineOptionChangeToken = updatedChangeTokens.lineOptionChangeToken
			changeTokens.modelImageChangeToken = updatedChangeTokens.modelImageChangeToken
			changeTokens.modelOptionChangeToken = updatedChangeTokens.modelOptionChangeToken
			changeTokens.modelOptionImageChangeToken = updatedChangeTokens.modelOptionImageChangeToken
			
			changeTokens.optionGroupChangeToken = updatedChangeTokens.optionGroupChangeToken
			changeTokens.optionImageChangeToken = updatedChangeTokens.optionImageChangeToken
			changeTokens.optionImageNdxChangeToken = updatedChangeTokens.optionImageNdxChangeToken
			changeTokens.optionItemChangeToken = updatedChangeTokens.optionItemChangeToken
			
			changeTokens.plantChangeToken = updatedChangeTokens.plantChangeToken
			changeTokens.productLineChangeToken = updatedChangeTokens.productLineChangeToken
			changeTokens.quickLookFloorplanChangeToken = updatedChangeTokens.quickLookFloorplanChangeToken
			
			changeTokens.quickLookNodeChangeToken = updatedChangeTokens.quickLookNodeChangeToken
			changeTokens.venueModelChangeToken = updatedChangeTokens.venueModelChangeToken
			changeTokens.changeToken = updatedChangeTokens.changeToken
			
			changeTokens.lastUpdatedBy = updatedChangeTokens.lastUpdatedBy

			return changeTokens.save(on: req)
		}
	}
	
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		
		return try req.parameters.next(ChangeTokens.self)
			.delete(on: req)
			.transform(to: HTTPStatus.noContent)
	}
	
	
	
	func getTokensWithIDHandler(_ req: Request) throws -> Future<ChangeTokens>
	{
		let appTokensID = try req.parameters.next(Int32.self)
		
		return ChangeTokens.query(on: req).group(.or) { or in
			or.filter(\.appTokensID == appTokensID)
		}.first().map(to: ChangeTokens.self) { tokens -> ChangeTokens in
			
			if let changeTokens = tokens
			{
				return changeTokens
			}
			else
			{
				throw Abort(.notFound)
			}
		}
	}

}









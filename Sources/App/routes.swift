import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
 
	
	// Register the model route controllers
	//
	let adminController = DbAdminController()
	
	try router.register(collection: adminController)
	
	let homeImageController = HomeImageController()
	
	try router.register(collection: homeImageController)
	
	let globalDefsController = HomeGuideGlobalController()
	
	try router.register(collection: globalDefsController)

	let modelImageNdxController = ModelImageNdxController()
	
	try router.register(collection: modelImageNdxController)
	
	let homeModelController = HomeModelController()
	
	try router.register(collection: homeModelController)
	
	let plantController = PlantController()
	
	try router.register(collection: plantController)
	
	let productLineController = ProductLineController()
	
	try router.register(collection: productLineController)
	
	let homeVenueController = HomeVenueController()
	
	try router.register(collection: homeVenueController)
	
	let venueModelController = VenueModelController()
	
	try router.register(collection: venueModelController)
	
	let venueModelImageController = VenueModelImageController()
	
	try router.register(collection: venueModelImageController)
	
	let brandController = BrandController()
	
	try router.register(collection: brandController)
	
	let homeSetController = HomeSetController()
	
	try router.register(collection: homeSetController)
	
	let homeSetModelController = HomeSetModelController()
	
	try router.register(collection: homeSetModelController)
	
	let changeTokensController = ChangeTokensController()
	
	try router.register(collection: changeTokensController)
		
}

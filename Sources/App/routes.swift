import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
 
	
	// Register the model route controllers
	//
	let adminController = DbAdminController()
	
	try router.register(collection: adminController)
	
/*
	let plantController = PlantController()
	
	try router.register(collection: plantController)
	
	
	let brandController = BrandController()
	
	try router.register(collection: brandController)
	
	
	let lineController = LineController()
	
	try router.register(collection: lineController)
	
	
	let modelController = ModelController()
	
	try router.register(collection: modelController)
	
	
	let modelImageController = ModelImageController()
	
	try router.register(collection: modelImageController)
	
	
	let imageController = ImageController()
	
	try router.register(collection: imageController)
*/
		
}

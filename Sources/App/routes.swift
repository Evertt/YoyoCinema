import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let movieController = MovieController()
    let authMiddleware = AuthMiddleware(apiKey: Environment.get("API_KEY")!)
    
    let protectedRoutes = router.grouped(authMiddleware)
    protectedRoutes.get("movies", use: movieController.index)
    protectedRoutes.get("movies", Movie.parameter, use: movieController.show)
}

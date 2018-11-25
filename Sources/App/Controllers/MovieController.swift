import Vapor
import FluentSQL

/// Controls basic CRUD operations on `Movie`s.
final class MovieController {
    /// Returns a list of `Movie`s, possibly filtered by a searchQuery.
    func index(_ req: Request) throws -> Future<[Movie]> {
        let searchQuery = try req.query.get(at: "searchQuery") as String?
        let movieQuery = Movie.query(on: req)
        
        if let searchQuery = searchQuery {
            movieQuery.filter(\.title ~~ searchQuery)
        }
        
        return movieQuery.all()
    }
    
    /// Returns a parameterized `Movie`
    func show(_ req: Request) throws -> Future<Movie> {
        return try req.parameters.next(Movie.self)
    }
}

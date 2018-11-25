@testable import App
import Vapor
import XCTest

final class AppTests: XCTestCase {
    var app: Application!
    var responder: Responder!
    var movie: Movie!
    var apiKey: String?

    override func setUp() {
        super.setUp()
        
        /// Normally I prefer not to use `try!`, but
        /// unfortunately I'm not allowed to `throw` in this method.

        self.apiKey = Environment.get("API_KEY")
        self.app = try! App.app(.testing)
        self.responder = try! app.make(Responder.self)
        self.movie = try! Movie(title: "Testing...")
            .save(on: Request(using: app)).wait()
    }
    
    func testAuthMiddleware(url: String) throws {
        /// If the `AuthMiddleware` is properly configured,
        /// the bare request should yield an `Unauthorized` error.
        let error: ErrorResponse = try get(url: url)
        XCTAssert(error.reason == "Unauthorized")
        
        /// And the authenticated request should yield no error.
        let authorizedURL = try authorized(url)
        try XCTAssert(200...399 ~= get(url: authorizedURL).http.status.code)
    }
    
    func testIndex() throws {
        var movies: [Movie] = []
        try testAuthMiddleware(url: "/movies")
        
        /// There should be one `Movie`
        movies = try get(url: authorized("/movies"))
        XCTAssert(movies.count == 1)
        
        /// There should be no `Movie` matching "foo"
        movies = try get(url: authorized("/movies?searchQuery=foo"))
        XCTAssert(movies.count == 0)
        
        /// There should be one `Movie` matching "test"
        movies = try get(url: authorized("/movies?searchQuery=test"))
        XCTAssert(movies.count == 1)
    }
    
    func testShow() throws {
        let correctId = self.movie.id!
        let wrongId = correctId + 1
        
        try testAuthMiddleware(url: "/movies/\(correctId)")
        
        /// A request with the correct `id` should return the correct `Movie`.
        let movie: Movie = try get(url: authorized("/movies/\(correctId)"))
        XCTAssertNotNil(movie.title == self.movie.title)
        
        /// A request with the wrong `id` should return a `notFound` error.
        let resp: Response = try get(url: authorized("/movies/\(wrongId)"))
        XCTAssert(resp.http.status == .notFound)
    }
    
    /// Makes a GET request and returns the response
    func get(url: String) throws -> Response {
        let httpReq = HTTPRequest(method: .GET, url: url)
        return try responder.respond(to: Request(http: httpReq, using: app)).wait()
    }
    
    /// Makes a GET request and tries to decode the response to the desired type
    func get<T>(url: String) throws -> T where T: Decodable {
        return try get(url: url).content.decode(T.self).wait()
    }
    
    /// Adds the api key to the query string of a url and returns the url
    func authorized(_ url: String) throws -> String {
        guard var components = URLComponents(string: url) else {
            throw "\"\(url)\" is not a url"
        }
        
        let apiKeyItem = URLQueryItem(name: "apiKey", value: apiKey)
        
        if components.queryItems != nil {
            components.queryItems!.append(apiKeyItem)
        } else {
            components.queryItems = [apiKeyItem]
        }
        
        return components.description
    }

    static let allTests = [
        ("testIndex", testIndex),
        ("testShow", testShow),
    ]
}

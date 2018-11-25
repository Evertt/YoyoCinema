import Vapor

class AuthMiddleware: Middleware {
    let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let apiKey = try request.query.get(at: "apiKey") as String?
        
        guard apiKey == self.apiKey else {
            throw Abort(.unauthorized)
        }
        
        return try next.respond(to: request)
    }
}

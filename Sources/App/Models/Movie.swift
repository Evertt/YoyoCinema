import FluentSQLite
import Vapor

/// A single entry of a Movie list.
final class Movie: SQLiteModel {
    /// The unique identifier for this `Movie`.
    var id: Int?

    /// The title of the `Movie`.
    var title: String

    /// Creates a new `Movie`.
    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

/// Allows `Movie` to be used as a dynamic migration.
extension Movie: Migration { }

/// Allows `Movie` to be encoded to and decoded from HTTP messages.
extension Movie: Content { }

/// Allows `Movie` to be used as a dynamic parameter in route definitions.
extension Movie: Parameter { }

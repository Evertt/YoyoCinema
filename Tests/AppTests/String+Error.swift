import Foundation

/// Enables you to throw a string
extension String: Error {}

/// Adds error.localizedDescription to Error instances
extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}

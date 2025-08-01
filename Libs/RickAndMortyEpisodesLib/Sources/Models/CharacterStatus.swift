import Foundation

/// A status of a "character" entity in "Rick and Morty app" domain.
struct ChracterStatus: StringRepresentable {
  var rawValue: String

  init(rawValue: String) {
    self.rawValue = rawValue
  }
}

// MARK: - constants
extension ChracterStatus {
  static let alive: ChracterStatus = "Alive"
  static let dead: ChracterStatus = "Dead"
  static let unknown: ChracterStatus = "unknown"
}

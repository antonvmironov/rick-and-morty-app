import Foundation
import SharedLib

/// A status of a "character" entity in "Rick and Morty app" domain.
struct CharacterStatus: StringRepresentable {
  var rawValue: String

  init(rawValue: String) {
    self.rawValue = rawValue
  }
}

// MARK: - constants
extension CharacterStatus {
  static let alive: CharacterStatus = "Alive"
  static let dead: CharacterStatus = "Dead"
  static let unknown: CharacterStatus = "unknown"
}

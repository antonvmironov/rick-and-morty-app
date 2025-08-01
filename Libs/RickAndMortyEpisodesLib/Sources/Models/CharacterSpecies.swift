import Foundation

/// A species of a "character" entity in "Rick and Morty app" domain.
struct ChracterSpecies: StringRepresentable {
  var rawValue: String

  init(rawValue: String) {
    self.rawValue = rawValue
  }
}

// MARK: - constants
extension ChracterSpecies {
  static let human: ChracterSpecies = "Human"
  static let humanoid: ChracterSpecies = "Humanoid"
  static let unknown: ChracterSpecies = "unknown"
}

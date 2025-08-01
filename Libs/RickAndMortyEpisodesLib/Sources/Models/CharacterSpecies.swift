import Foundation

/// A species of a "character" entity in "Rick and Morty app" domain.
struct CharacterSpecies: StringRepresentable {
  var rawValue: String

  init(rawValue: String) {
    self.rawValue = rawValue
  }
}

// MARK: - constants
extension CharacterSpecies {
  static let human: CharacterSpecies = "Human"
  static let humanoid: CharacterSpecies = "Humanoid"
  static let unknown: CharacterSpecies = "unknown"
}

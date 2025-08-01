import Foundation

/// A species of a "character" entity in "Rick and Morty app" domain.
struct RickAndMortyCharacterSpecies: StringRepresentable {
  var rawValue: String

  init(rawValue: String) {
    self.rawValue = rawValue
  }
}

// MARK: - constants
extension RickAndMortyCharacterSpecies {
  static let human: RickAndMortyCharacterSpecies = "Human"
  static let humanoid: RickAndMortyCharacterSpecies = "Humanoid"
  static let unknown: RickAndMortyCharacterSpecies = "unknown"
}

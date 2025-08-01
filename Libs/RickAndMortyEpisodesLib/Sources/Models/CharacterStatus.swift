import Foundation

/// A status of a "character" entity in "Rick and Morty app" domain.
struct RickAndMortyCharacterStatus: StringRepresentable {
  var rawValue: String

  init(rawValue: String) {
    self.rawValue = rawValue
  }
}

// MARK: - constants
extension RickAndMortyCharacterStatus {
  static let alive: RickAndMortyCharacterStatus = "Alive"
  static let dead: RickAndMortyCharacterStatus = "Dead"
  static let unknown: RickAndMortyCharacterStatus = "unknown"
}

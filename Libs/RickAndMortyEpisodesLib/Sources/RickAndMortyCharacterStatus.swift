import Foundation

/// A status of a "character" entity in "Rick and Morty app" domain.
struct RickAndMortyCharacterStatus: Sendable, Equatable {
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

// MARK: - conformances
extension RickAndMortyCharacterStatus: Codable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self.init(rawValue: rawValue)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}

extension RickAndMortyCharacterStatus: CustomStringConvertible {
  var description: String { rawValue }
}

extension RickAndMortyCharacterStatus: ExpressibleByStringLiteral {
  init(stringLiteral rawValue: String) {
    self.init(rawValue: rawValue)
  }
}

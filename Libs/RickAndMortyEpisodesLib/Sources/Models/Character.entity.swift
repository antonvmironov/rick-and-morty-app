import Foundation

typealias CharacterID = Int

/// A domain model of "character" entity in "RickAndMorty" domain.
struct CharacterDomainModel: Sendable,
  Codable,
  Equatable,
  Identifiable
{
  let id: CharacterID
  let name: String
  let status: CharacterStatus
  let species: CharacterSpecies
  let type: String
  let gender: String
  let origin: Location
  let location: Location
  let image: URL
  let episode: [URL]
  let url: URL
  let created: Date
}

// Helper struct for origin and location fields
struct Location: Codable, Equatable, Sendable {
  let name: String
  let url: URL
}

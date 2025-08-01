import Foundation

typealias RickAndMortyCharacterID = Int

/// A domain model of "character" entity in "RickAndMorty" domain.
struct RickAndMortyCharacterDomainModel: Sendable,
  Codable,
  Equatable,
  Identifiable
{
  let id: RickAndMortyCharacterID
  let name: String
  let status: RickAndMortyCharacterStatus
  let species: RickAndMortyCharacterSpecies
  let type: String
  let gender: String
  let origin: RickAndMortyLocation
  let location: RickAndMortyLocation
  let image: URL
  let episode: [URL]
  let url: URL
  let created: Date
}

// Helper struct for origin and location fields
struct RickAndMortyLocation: Codable, Equatable, Sendable {
  let name: String
  let url: URL
}

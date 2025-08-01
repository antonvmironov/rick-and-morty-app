import Foundation

typealias ChracterID = Int

/// A domain model of "character" entity in "RickAndMorty" domain.
struct ChracterDomainModel: Sendable,
  Codable,
  Equatable,
  Identifiable
{
  let id: ChracterID
  let name: String
  let status: CharacterStatus
  let species: ChracterSpecies
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

import Foundation

typealias RickAndMortyLocationID = Int

/// A domain model of "location" entity in "RickAndMorty" domain.
struct RickAndMortyLocationDomainModel: Sendable, Codable, Equatable,
  Identifiable
{
  let id: RickAndMortyLocationID
  let name: String
  let type: String
  let dimension: String
  let residents: [URL]
  let url: URL
  let created: Date
}

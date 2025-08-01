import Foundation

typealias LocationID = Int

/// A domain model of "location" entity in "RickAndMorty" domain.
struct LocationDomainModel: Sendable, Codable, Equatable,
  Identifiable
{
  let id: LocationID
  let name: String
  let type: String
  let dimension: String
  let residents: [URL]
  let url: URL
  let created: Date
}

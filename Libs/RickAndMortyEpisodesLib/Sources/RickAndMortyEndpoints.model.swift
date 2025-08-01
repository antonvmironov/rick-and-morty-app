import Foundation

// A domain model of "endpoints" entity in "RickAndMorty" domain.
struct RickAndMortyEndpointsDomainModel: Sendable, Codable, Equatable {
  var characters: URL
  var locations: URL
  var episodes: URL
}

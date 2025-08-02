import Foundation

// A domain model of "endpoints" entity in "RickAndMorty" domain.
struct EndpointsDomainModel: Sendable, Codable, Equatable {
  var characters: URL
  var locations: URL
  var episodes: URL

  static let mock = EndpointsDomainModel(
    characters: URL(string: "https://rickandmortyapi.com/api/character")!,
    locations: URL(string: "https://rickandmortyapi.com/api/location")!,
    episodes: URL(string: "https://rickandmortyapi.com/api/episode")!
  )
}

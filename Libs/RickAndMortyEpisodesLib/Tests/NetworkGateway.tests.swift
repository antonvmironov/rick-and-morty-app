import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("NetworkGateway test episodeList")
func NetworkGateway_episodeList() async throws {
  let apiURL = URL(string: "https://rickandmortyapi.com/api")!
  let mock = try MockNetworkGateway.empty().expecting(
    requestURL: apiURL,
    jsonFixtureNamed: "endpoints"
  )
  let endpoints = try await mock.getEndpoints(
    apiURL: apiURL,
    ignoreCache: false
  )
  #expect(
    endpoints.characters == apiURL.appendingPathComponent("character")
  )
  #expect(
    endpoints.locations == apiURL.appendingPathComponent("location")
  )
  #expect(
    endpoints.episodes == apiURL.appendingPathComponent("episode")
  )
}

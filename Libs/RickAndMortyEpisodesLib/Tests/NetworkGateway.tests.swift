import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("NetworkGateway test episodeList")
func NetworkGateway_episodeList() async throws {
  let apiURL = URL(string: "https://rickandmortyapi.com/api")!
  var networkGateway = MockNetworkGateway.empty()
  try networkGateway.expect(
    requestURL: apiURL,
    jsonFixtureNamed: "endpoints"
  )
  let (endpoints, cachedSince) = try await networkGateway.getEndpoints(
    apiURL: apiURL,
    cachePolicy: .useProtocolCachePolicy
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
  #expect(cachedSince == MockNetworkGateway.cachedSinceDate)
}

extension MockNetworkGateway {
  mutating func expect(
    requestURL: URL,
    statusCode: Int = 200,
    jsonFixtureNamed fixtureName: String
  ) throws {
    let url = Bundle.module.url(
      forResource: fixtureName,
      withExtension: "json"
    )!
    let data = try Data(contentsOf: url)
    expect(requestURL: requestURL, statusCode: statusCode, data: data)
  }
}

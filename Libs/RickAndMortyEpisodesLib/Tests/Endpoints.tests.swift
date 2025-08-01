import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("EndpointsDomainModel initializes with correct URLs")
func EndpointsDomainModel_initializes_with_correct_URLs() {
  let model = EndpointsDomainModel(
    characters: charactersEndpointURL,
    locations: locationsEndpointURL,
    episodes: episodesEndpointURL
  )
  #expect(model.characters == charactersEndpointURL)
  #expect(model.locations == locationsEndpointURL)
  #expect(model.episodes == episodesEndpointURL)
  #expect(model == model)
}

@Test("EndpointsDomainModel Codable conformance")
func EndpointsDomainModel_Codable_conformance() throws {
  let model = EndpointsDomainModel(
    characters: charactersEndpointURL,
    locations: locationsEndpointURL,
    episodes: episodesEndpointURL
  )
  try TestUtils.expectEqualityAfterCodableRoundTrip(model)
}

private let charactersEndpointURL = URL(
  string: "https://rickandmortyapi.com/api/character"
)!
private let locationsEndpointURL = URL(
  string: "https://rickandmortyapi.com/api/location"
)!
private let episodesEndpointURL = URL(
  string: "https://rickandmortyapi.com/api/episode"
)!

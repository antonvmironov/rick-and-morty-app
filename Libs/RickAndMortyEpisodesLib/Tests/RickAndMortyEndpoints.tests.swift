import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("RickAndMortyEndpointsDomainModel initializes with correct URLs")
func RickAndMortyEndpointsDomainModel_initializes_with_correct_URLs() {
  let model = RickAndMortyEndpointsDomainModel(
    characters: charactersEndpointURL,
    locations: locationsEndpointURL,
    episodes: episodesEndpointURL
  )
  #expect(model.characters == charactersEndpointURL)
  #expect(model.locations == locationsEndpointURL)
  #expect(model.episodes == episodesEndpointURL)
  #expect(model == model)
}

@Test("RickAndMortyEndpointsDomainModel Codable conformance")
func RickAndMortyEndpointsDomainModel_Codable_conformance() throws {
  let model = RickAndMortyEndpointsDomainModel(
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

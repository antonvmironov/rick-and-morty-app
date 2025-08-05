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
  let response =
    try await networkGateway
    .get(operation: NetworkOperation.endpoints(apiURL: apiURL))
  let endpoints = response.decodedResponse
  #expect(
    endpoints.characters == apiURL.appendingPathComponent("character")
  )
  #expect(
    endpoints.locations == apiURL.appendingPathComponent("location")
  )
  #expect(
    endpoints.episodes == apiURL.appendingPathComponent("episode")
  )
  #expect(response.cachedSince == MockNetworkGateway.cachedSinceDate)
}

// MARK: - character
@Test("NetworkGateway test getCharacter")
func NetworkGateway_getCharacter() async throws {
  let apiURL = URL(string: "https://rickandmortyapi.com/api")!
  var networkGateway = MockNetworkGateway.empty()
  try networkGateway.expect(
    requestURL: apiURL,
    jsonFixtureNamed: "endpoints"
  )
  let endpoints = EndpointsDomainModel.mock
  let characterID: CharacterID = 1
  let characterURL = endpoints.characters.appendingPathComponent(
    "\(characterID)"
  )
  try networkGateway.expect(
    requestURL: characterURL,
    jsonFixtureNamed: "character_rick"
  )
  let response = try await networkGateway.get(
    operation: NetworkOperation.character(
      endpoints: endpoints,
      id: characterID
    )
  )
  let character = response.decodedResponse
  #expect(character.id == characterID)
  #expect(character.name == "Rick Sanchez")
  #expect(response.cachedSince == MockNetworkGateway.cachedSinceDate)
}

@Test("NetworkGateway test getPageOfCharacters")
func NetworkGateway_getPageOfCharacters() async throws {
  let pageURL = URL(string: "https://rickandmortyapi.com/api/character?page=1")!
  var networkGateway = MockNetworkGateway.empty()
  try networkGateway.expect(
    requestURL: pageURL,
    jsonFixtureNamed: "characters_first_page"
  )
  let response = try await networkGateway.get(
    operation: NetworkOperation.pageOfCharacters(pageURL: pageURL)
  )
  let page = response.decodedResponse.payload
  #expect(page.results.count > 0)
  #expect(page.info.pages >= 1)
  let result = page.results[0]
  #expect(result.id == 1)
  #expect(result.name == "Rick Sanchez")
  #expect(response.cachedSince == MockNetworkGateway.cachedSinceDate)
}

// MARK: - location
@Test("NetworkGateway test getLocation")
func NetworkGateway_getLocation() async throws {
  let apiURL = URL(string: "https://rickandmortyapi.com/api")!
  var networkGateway = MockNetworkGateway.empty()
  try networkGateway.expect(
    requestURL: apiURL,
    jsonFixtureNamed: "endpoints"
  )
  let endpoints = EndpointsDomainModel.mock
  let locationID: LocationID = 1
  let locationURL = endpoints.locations.appendingPathComponent("\(locationID)")
  try networkGateway.expect(
    requestURL: locationURL,
    jsonFixtureNamed: "location_earth1"
  )
  let response = try await networkGateway.get(
    operation: NetworkOperation.location(endpoints: endpoints, id: locationID)
  )
  let location = response.decodedResponse
  #expect(location.id == locationID)
  #expect(location.name == "Earth (C-137)")
  #expect(location.type == "Planet")
  #expect(location.dimension == "Dimension C-137")
  #expect(location.residents.count == 27)
  #expect(response.cachedSince == MockNetworkGateway.cachedSinceDate)
}

@Test("NetworkGateway test getPageOfLocations")
func NetworkGateway_getPageOfLocations() async throws {
  let pageURL = URL(string: "https://rickandmortyapi.com/api/location?page=1")!
  var networkGateway = MockNetworkGateway.empty()
  try networkGateway.expect(
    requestURL: pageURL,
    jsonFixtureNamed: "locations_first_page"
  )
  let response = try await networkGateway.get(
    operation: NetworkOperation.pageOfLocations(pageURL: pageURL)
  )
  let page = response.decodedResponse.payload
  #expect(page.results.count == 20)
  #expect(page.info.pages == 7)
  var result = page.results[0]
  #expect(result.id == 1)
  #expect(result.name == "Earth (C-137)")
  result = page.results[19]
  #expect(result.id == 20)
  #expect(result.name == "Earth (Replacement Dimension)")
  #expect(response.cachedSince == MockNetworkGateway.cachedSinceDate)
}

// MARK: - episode

@Test("NetworkGateway test getEpisode")
func NetworkGateway_getEpisode() async throws {
  let apiURL = URL(string: "https://rickandmortyapi.com/api")!
  var networkGateway = MockNetworkGateway.empty()
  try networkGateway.expect(
    requestURL: apiURL,
    jsonFixtureNamed: "endpoints"
  )
  let endpoints = EndpointsDomainModel.mock
  let episodeID: EpisodeID = 1
  let episodeURL = endpoints.episodes.appendingPathComponent("\(episodeID)")
  try networkGateway.expect(
    requestURL: episodeURL,
    jsonFixtureNamed: "episode_pilot"
  )
  let response = try await networkGateway.get(
    operation: NetworkOperation.episode(endpoints: endpoints, id: episodeID),
  )
  let episode = response.decodedResponse
  #expect(episode.id == episodeID)
  #expect(episode.name == "Pilot")
  #expect(episode.episode == "S01E01")
  #expect(episode.characters.count == 19)
  #expect(response.cachedSince == MockNetworkGateway.cachedSinceDate)
}

@Test("NetworkGateway test getPageOfEpisodes")
func NetworkGateway_getPageOfEpisodes() async throws {
  let pageURL = URL(string: "https://rickandmortyapi.com/api/episode?page=1")!
  var networkGateway = MockNetworkGateway.empty()
  try networkGateway.expect(
    requestURL: pageURL,
    jsonFixtureNamed: "episodes_first_page"
  )
  let response = try await networkGateway.get(
    operation: NetworkOperation.pageOfEpisodes(pageURL: pageURL)
  )
  let page = response.decodedResponse.payload
  #expect(page.results.count == 20)
  #expect(page.info.pages == 3)
  var result = page.results[0]
  #expect(result.id == 1)
  #expect(result.name == "Pilot")
  result = page.results[19]
  #expect(result.id == 20)
  #expect(result.name == "Look Who's Purging Now")
  #expect(response.cachedSince == MockNetworkGateway.cachedSinceDate)
}

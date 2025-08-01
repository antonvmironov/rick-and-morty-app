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
  let (character, cachedSince) = try await networkGateway.getCharacter(
    endpoints: endpoints,
    id: characterID,
    cachePolicy: .useProtocolCachePolicy
  )
  #expect(character.id == characterID)
  #expect(character.name == "Rick Sanchez")
  #expect(cachedSince == MockNetworkGateway.cachedSinceDate)
}

@Test("NetworkGateway test getPageOfCharacters")
func NetworkGateway_getPageOfCharacters() async throws {
  let pageURL = URL(string: "https://rickandmortyapi.com/api/character?page=1")!
  var networkGateway = MockNetworkGateway.empty()
  try networkGateway.expect(
    requestURL: pageURL,
    jsonFixtureNamed: "characters_first_page"
  )
  let (page, cachedSince) = try await networkGateway.getPageOfCharacters(
    pageURL: pageURL,
    cachePolicy: .useProtocolCachePolicy
  )
  #expect(page.results.count > 0)
  #expect(page.info.pages >= 1)
  #expect(page.results.first?.id == 1)
  #expect(page.results.first?.name == "Rick Sanchez")
  #expect(cachedSince == MockNetworkGateway.cachedSinceDate)
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
  let (location, cachedSince) = try await networkGateway.getLocation(
    endpoints: endpoints,
    id: locationID,
    cachePolicy: .useProtocolCachePolicy
  )
  #expect(location.id == locationID)
  #expect(location.name == "Earth (C-137)")
  #expect(location.type == "Planet")
  #expect(location.dimension == "Dimension C-137")
  #expect(location.residents.count == 27)
  #expect(cachedSince == MockNetworkGateway.cachedSinceDate)
}

@Test("NetworkGateway test getPageOfLocations")
func NetworkGateway_getPageOfLocations() async throws {
  let pageURL = URL(string: "https://rickandmortyapi.com/api/location?page=1")!
  var networkGateway = MockNetworkGateway.empty()
  try networkGateway.expect(
    requestURL: pageURL,
    jsonFixtureNamed: "locations_first_page"
  )
  let (page, cachedSince) = try await networkGateway.getPageOfLocations(
    pageURL: pageURL,
    cachePolicy: .useProtocolCachePolicy
  )
  #expect(page.results.count == 20)
  #expect(page.info.pages == 7)
  #expect(page.results.first?.id == 1)
  #expect(page.results.first?.name == "Earth (C-137)")
  #expect(page.results.last?.id == 20)
  #expect(page.results.last?.name == "Earth (Replacement Dimension)")
  #expect(cachedSince == MockNetworkGateway.cachedSinceDate)
}

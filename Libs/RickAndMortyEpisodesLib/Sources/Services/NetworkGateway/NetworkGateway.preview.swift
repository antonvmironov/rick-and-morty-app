import Foundation
import SharedLib

extension MockNetworkGateway {
  static let exampleAPIURL = URL(string: "https://rickandmortyapi.com/api/")!
  static let episodesFirstPageAPIURL = exampleAPIURL.appendingPathComponent(
    "episode"
  )
  static let episodeFirstPageAPIURL = exampleAPIURL.appendingPathComponent(
    "episode/1"
  )
  static let charactersFirstPageAPIURL = exampleAPIURL.appendingPathComponent(
    "character"
  )
  static let characterFirstAPIURL = exampleAPIURL.appendingPathComponent(
    "character/1"
  )
  static let locationsFirstPageAPIURL = exampleAPIURL.appendingPathComponent(
    "location"
  )
  static let locationFirstAPIURL = exampleAPIURL.appendingPathComponent(
    "location/1"
  )

  #if DEBUG
    mutating func expect(
      requestURL: URL,
      statusCode: Int = 200,
      jsonFixtureNamed fixtureName: String
    ) throws {
      let data = try Transformers.loadFixture(fixtureName: fixtureName)
      expect(requestURL: requestURL, statusCode: statusCode, data: data)
    }

    static func preview() throws -> MockNetworkGateway {
      var result = MockNetworkGateway.empty()
      try result.expect(
        requestURL: exampleAPIURL,
        jsonFixtureNamed: "endpoints"
      )
      try result.expect(
        requestURL: episodesFirstPageAPIURL,
        jsonFixtureNamed: "episodes_first_page"
      )
      try result.expect(
        requestURL: episodeFirstPageAPIURL,
        jsonFixtureNamed: "episode_pilot"
      )
      try result.expect(
        requestURL: charactersFirstPageAPIURL,
        jsonFixtureNamed: "characters_first_page"
      )
      try result.expect(
        requestURL: characterFirstAPIURL,
        jsonFixtureNamed: "character_rick"
      )
      try result.expect(
        requestURL: locationsFirstPageAPIURL,
        jsonFixtureNamed: "locations_first_page"
      )
      try result.expect(
        requestURL: locationFirstAPIURL,
        jsonFixtureNamed: "location_earth1"
      )
      return result
    }
  #endif
}

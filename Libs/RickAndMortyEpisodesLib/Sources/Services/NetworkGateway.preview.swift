import Foundation

extension MockNetworkGateway {
  static let exampleAPIURL = URL(string: "https://rickandmortyapi.com/api/")!

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
        requestURL: exampleAPIURL.appendingPathComponent("episode"),
        jsonFixtureNamed: "episodes_first_page"
      )
      return result
    }
  #endif
}

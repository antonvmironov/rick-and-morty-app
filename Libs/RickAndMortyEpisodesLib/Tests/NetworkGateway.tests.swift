import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

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

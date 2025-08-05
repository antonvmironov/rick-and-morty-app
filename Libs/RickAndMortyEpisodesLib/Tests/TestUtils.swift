import Foundation
import SharedLib
import Testing

@testable import RickAndMortyEpisodesLib

enum TestUtils {
  static func expectEqualityAfterCodableRoundTrip<T: Codable & Equatable>(
    _ value: T,
    sourceLocation: SourceLocation = #_sourceLocation,
  ) throws {
    let encoder = Transformers.jsonEncoder()
    let data = try encoder.encode(value)
    let decoder = Transformers.jsonDecoder()
    let decoded = try decoder.decode(T.self, from: data)
    #expect(
      decoded == value,
      "\(T.self) is not equal after codable round trip",
      sourceLocation: sourceLocation
    )
  }

  static func dateFromString(_ string: String) -> Date {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [
      .withInternetDateTime,
      .withTimeZone,
      .withFractionalSeconds,
    ]
    if let date = formatter.date(from: string) {
      return date
    } else {
      fatalError(
        "Should never happen in tests. Failed to decode from \(string)"
      )
    }
  }
}

extension StringProtocol {
  var utf8Data: Data { Data(utf8) }
}

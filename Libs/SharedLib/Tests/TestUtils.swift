import Foundation
import Testing

enum TestUtils {
  static func expectEqualityAfterCodableRoundTrip<T: Codable & Equatable>(
    _ value: T,
    sourceLocation: SourceLocation = #_sourceLocation,
  ) throws {
    let encoder = JSONEncoder()
    let data = try encoder.encode(value)
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(T.self, from: data)
    #expect(
      decoded == value,
      "\(T.self) is not equal after codable round trip",
      sourceLocation: sourceLocation
    )
  }
}

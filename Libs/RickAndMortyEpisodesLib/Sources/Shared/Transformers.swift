import ComposableArchitecture
import Foundation

/// A namespace for functionality shared for serialization
enum Transformers {
  static func dateFormatter() -> ISO8601DateFormatter {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [
      .withInternetDateTime,
      .withTimeZone,
      .withFractionalSeconds,
    ]
    return formatter
  }

  static func jsonDecoder() -> JSONDecoder {
    let lockedDateFormatter = LockIsolated(dateFormatter())
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let stringValue = try decoder.singleValueContainer().decode(String.self)
      if let date = lockedDateFormatter.withValue({ $0.date(from: stringValue) }
      ) {
        return date
      } else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [], debugDescription: "Unsupported date format")
        )
      }
    }
    return decoder
  }

  #if DEBUG
    static func loadFixture(
      fixtureName: String,
    ) throws -> Data {
      let thisFileURL = URL(fileURLWithPath: #file)
      let fixturesURL =
        thisFileURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Fixtures", isDirectory: true)
        .appendingPathComponent("\(fixtureName).json", isDirectory: false)
        .standardized

      return try Data(contentsOf: fixturesURL)
    }

    static func loadFixture<Output: Decodable>(
      output: Output.Type = Output.self,
      fixtureName: String,
    ) throws -> Output {
      let fixtureData = try loadFixture(fixtureName: fixtureName)
      return try jsonDecoder().decode(Output.self, from: fixtureData)
    }
  #endif
}

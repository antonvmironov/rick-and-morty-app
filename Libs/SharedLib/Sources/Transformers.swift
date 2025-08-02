import ComposableArchitecture
import Foundation

/// A namespace for functionality shared for serialization
public enum Transformers {
  public static func dateFormatter() -> ISO8601DateFormatter {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [
      .withInternetDateTime,
      .withTimeZone,
      .withFractionalSeconds,
    ]
    return formatter
  }

  public static func jsonDecoder() -> JSONDecoder {
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
    public static func loadFixture(
      fixtureName: String,
      invokedFrom: StaticString = #filePath,
    ) throws -> Data {
      var thisFileURL = URL(fileURLWithPath: "\(invokedFrom)")
      while thisFileURL.lastPathComponent != "Sources" {
        thisFileURL = thisFileURL.deletingLastPathComponent()
      }
      let fixturesURL =
        thisFileURL
        .deletingLastPathComponent()
        .appendingPathComponent("Fixtures", isDirectory: true)
        .appendingPathComponent("\(fixtureName).json", isDirectory: false)
        .standardized

      return try Data(contentsOf: fixturesURL)
    }

    public static func loadFixture<Output: Decodable>(
      output: Output.Type = Output.self,
      fixtureName: String,
      invokedFrom: StaticString = #filePath,
    ) throws -> Output {
      let fixtureData = try loadFixture(
        fixtureName: fixtureName,
        invokedFrom: invokedFrom
      )
      return try jsonDecoder().decode(Output.self, from: fixtureData)
    }
  #endif
}

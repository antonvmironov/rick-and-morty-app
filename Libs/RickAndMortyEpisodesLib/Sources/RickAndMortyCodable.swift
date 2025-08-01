import ComposableArchitecture
import Foundation

/// A namespace for functionality shared for serialization
enum RickAndMortyCodable {
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
}

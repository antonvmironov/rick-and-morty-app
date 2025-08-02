import Foundation

/// A protocol for types that represent entities using an underlying String value.
///
/// Adopt this protocol to create distinct types backed by strings, enabling type safety, clear separation between entities, and the ability to define shared constants or utility methods.
public protocol StringRepresentable: Sendable,
                                     Equatable,
                                     Codable,
                                     CustomStringConvertible,
                                     ExpressibleByStringLiteral {
  var rawValue: String { get set }
  init(rawValue: String)
}

extension StringRepresentable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self.init(rawValue: rawValue)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }

  public var description: String { rawValue }

  public init(stringLiteral rawValue: String) {
    self.init(rawValue: rawValue)
  }
}

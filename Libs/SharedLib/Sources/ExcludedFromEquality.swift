/// A property wrapper that excludes its wrapped value from `Equatable` conformance checks.
/// As long as the property is wrapped with `@ExcludedFromEquality`, equality will always return true for this property.
@propertyWrapper
public struct ExcludedFromEquality<Value> {
  public var wrappedValue: Value

  public init(wrappedValue: Value) {
    self.wrappedValue = wrappedValue
  }
}

// Custom Equatable conformance: always equal if types match
extension ExcludedFromEquality: Hashable {
  public static func == (
    lhs: ExcludedFromEquality<Value>,
    rhs: ExcludedFromEquality<Value>
  ) -> Bool {
    // Always return true as long as the types match
    true
  }

  public func hash(into hasher: inout Hasher) {
    // No influence on hash
  }
}

extension ExcludedFromEquality: Sendable where Value: Sendable {}

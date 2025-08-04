import ComposableArchitecture
import Foundation
import SwiftUI

public protocol Feature {
  associatedtype FeatureView: View
  associatedtype FeatureReducer: Reducer<FeatureState, FeatureAction>
  associatedtype FeatureState: Equatable
  associatedtype FeatureAction

  typealias FeatureStore = StoreOf<FeatureReducer>
  associatedtype TestStore = TestStoreOf<FeatureReducer>
}

public protocol A11yIDProvider {
  var a11yID: String { get }
}

extension A11yIDProvider where Self: RawRepresentable, Self.RawValue == String {
  var a11yID: String { rawValue }
}

extension View {
  public func a11yID<A: A11yIDProvider>(
    _ provider: A,
    isHidden: Bool = false
  ) -> some View {
    accessibilityIdentifier(provider.a11yID)
      .accessibilityElement()
      .accessibilityHidden(true, isEnabled: !isHidden)
  }
}

import ComposableArchitecture
import Foundation
import SwiftUI

public protocol Feature {
  associatedtype FeatureReducer: Reducer<FeatureState, FeatureAction>
  associatedtype FeatureState: Equatable
  associatedtype FeatureAction

  typealias FeatureStore = StoreOf<FeatureReducer>
  associatedtype TestStore = TestStoreOf<FeatureReducer>
}

public protocol A11yIDProvider {
  var a11yID: String { get }
}

extension View {
  public func a11yID<A: A11yIDProvider>(
    _ provider: A,
  ) -> some View {
    accessibilityIdentifier(provider.a11yID)
  }
}

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

extension View {
  func accessibilityIdentifier<F: Feature>(
    feature: F.Type = F.self,
    _ featureKeyPath: KeyPath<F.Type, String>
  ) -> some View {
    accessibilityIdentifier(feature[keyPath: featureKeyPath])
  }
}

import Foundation
import SharedLib
import SwiftUI

/// Namespace for the StoreHost feature. Serves as an anchor for project navigation.
enum StoreHostFeature {
  struct FeatureViewModifier: ViewModifier {
    @Environment(\.canSendActions)
    var canSendActions: Bool

    var isEnabled: Bool

    func body(content: Content) -> some View {
      content.environment(\.canSendActions, isEnabled && canSendActions)
    }
  }
}

extension View {
  func storeActions(isEnabled: Bool) -> some View {
    modifier(StoreHostFeature.FeatureViewModifier(isEnabled: isEnabled))
  }
}

enum CanSendActions: EnvironmentKey {
  static var defaultValue: Bool { true }
}

extension EnvironmentValues {
  public var canSendActions: Bool {
    get { self[CanSendActions.self] }
    set { self[CanSendActions.self] = newValue }
  }
}

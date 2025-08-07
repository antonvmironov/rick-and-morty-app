import Foundation
import SwiftUI

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

import Foundation
import SharedLib
import SwiftUI

/// Namespace for the TagDecoration feature. Serves as an anchor for project navigation.
enum TagDecorationFeature {
  struct FeatureViewModifier: ViewModifier {
    func body(content: Content) -> some View {
      return
        content
        .padding(UIConstants.space / 2)
        .cornerRadius(UIConstants.cornerRadius)
        .overlay(
          RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
            .stroke(Color.accentColor, lineWidth: UIConstants.borderWidth)
        )
    }
  }
}

extension View {
  func tagDecoration() -> some View {
    modifier(TagDecorationFeature.FeatureViewModifier())
  }
}

// MARK: - preview

#Preview {
  VStack {
    Text("Hello, world!").tagDecoration()
  }
}

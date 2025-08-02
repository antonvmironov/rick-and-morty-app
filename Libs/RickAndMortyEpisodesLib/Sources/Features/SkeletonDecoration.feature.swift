import Foundation
import SharedLib
import Shimmer
import SwiftUI

/// Namespace for the SkeletonDecoration feature. Serves as an anchor for project navigation.
enum SkeletonDecorationFeature {
  struct FeatureViewModifier: ViewModifier {
    var isEnabled: Bool
    var redactionReasons: RedactionReasons
    func body(content: Content) -> some View {
      if isEnabled {
        content
          .redacted(reason: redactionReasons)
          .shimmering()
          .transition(.opacity.animation(.smooth))
          .allowsHitTesting(false)
      } else {
        content
          .transition(.opacity.animation(.smooth))
      }
    }
  }
}

extension View {
  func skeletonDecoration(
    isEnabled: Bool,
    redactionReasons: RedactionReasons = .placeholder
  ) -> some View {
    modifier(
      SkeletonDecorationFeature.FeatureViewModifier(
        isEnabled: isEnabled,
        redactionReasons: redactionReasons
      )
    )
  }
}

// MARK: - preview

#Preview {
  @Previewable @State var isPlaceholderEnabled = false

  VStack {
    Text("Disabled")
      .skeletonDecoration(isEnabled: false)
    Text("Enabled with default redaction reasons")
      .skeletonDecoration(isEnabled: true)
    Text("Enabled with 'invalidated' redaction reasons")
      .skeletonDecoration(isEnabled: true, redactionReasons: .invalidated)
    Text("Enabled with 'privacy' redaction reasons")
      .skeletonDecoration(isEnabled: true, redactionReasons: .privacy)
    Text("Enabled with 'invalidated' placeholder reasons")
      .skeletonDecoration(isEnabled: true, redactionReasons: .placeholder)

    VStack {
      Toggle(isOn: $isPlaceholderEnabled) {
        Text("is placeholder enabled")
      }
      Text("Quick fox jumps over the lazy dog.")
        .skeletonDecoration(
          isEnabled: isPlaceholderEnabled,
          redactionReasons: .placeholder
        )
        .tag("tagged")
    }
  }
}

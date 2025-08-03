import Foundation
import SharedLib
import Shimmer
import SwiftUI

/// Namespace for the SkeletonDecoration feature. Serves as an anchor for project navigation.
enum SkeletonDecorationFeature {
  struct FeatureViewModifier: ViewModifier {
    var isEnabled: Bool = true
    var isShimmering: Bool = true
    var redactionReasons: RedactionReasons = .placeholder
    func body(content: Content) -> some View {
      if isEnabled {
        content
          .redacted(reason: redactionReasons)
          .shimmering(active: isShimmering)
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
    isEnabled: Bool = true,
    isShimmering: Bool = true,
    redactionReasons: RedactionReasons = .placeholder
  ) -> some View {
    modifier(
      SkeletonDecorationFeature.FeatureViewModifier(
        isEnabled: isEnabled,
        isShimmering: isShimmering,
        redactionReasons: redactionReasons
      )
    )
  }
}

// MARK: - preview

#Preview {
  @Previewable @State var isPlaceholderEnabled = false
  @Previewable @State var isShimmaring = false

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
      Toggle(isOn: $isShimmaring) {
        Text("is shimmering enabled")
      }
      Text("Quick fox jumps over the lazy dog.")
        .skeletonDecoration(
          isEnabled: isPlaceholderEnabled,
          isShimmering: isShimmaring,
          redactionReasons: .placeholder
        )
        .tag("tagged")
    }
  }
}

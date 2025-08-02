import ComposableArchitecture
import Flow
import Foundation
import Kingfisher
import SharedLib
import Shimmer
import SwiftUI

/// Namespace for the CharacterBrief feature. Serves as an anchor for project navigation.
enum CharacterBriefFeature {
  struct FeatureView: View {
    var state: FeatureState

    init(state: FeatureState) {
      self.state = state
    }

    var body: some View {
      VStack(alignment: .leading) {
        Text(state.character.name)
          .font(.headline)
          .skeletonDecoration(isEnabled: state.isPlaceholder)
        HFlow {
          Group {
            Text(state.character.species.description)
              .skeletonDecoration(isEnabled: state.isPlaceholder)
            if !state.character.type.isEmpty {
              Text("species: \(state.character.type)")
                .skeletonDecoration(isEnabled: state.isPlaceholder)
            }
            Text("origin: \(state.character.origin.name)")
              .skeletonDecoration(isEnabled: state.isPlaceholder)
          }
          .font(.body)
          .tagDecoration()
          Spacer()
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var character: CharacterDomainModel
    var isPlaceholder: Bool

    static func preview(isPlaceholder: Bool) -> Self {
      .init(character: .dummy, isPlaceholder: isPlaceholder)
    }
  }
}

#Preview {
  VStack {
    CharacterBriefFeature.FeatureView(
      state: .preview(isPlaceholder: true)
    )
    CharacterBriefFeature.FeatureView(
      state: .preview(isPlaceholder: false)
    )
  }
  .frame(maxWidth: .infinity)
}

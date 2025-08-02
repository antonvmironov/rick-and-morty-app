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
        Text(state.character.name).font(.headline)
        HFlow {
          Group {
            Text(state.character.species.description)
            if !state.character.type.isEmpty {
              Text(state.character.type)
            }
          }
          .font(.body)
          .tagDecoration()
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var character: CharacterDomainModel
    var hasShimmer: Bool

    static func preview(hasShimmer: Bool) -> Self {
      .init(character: .dummy, hasShimmer: hasShimmer)
    }
  }
}

#Preview {
  VStack {
    CharacterBriefFeature.FeatureView(
      state: .preview(hasShimmer: true)
    )
    CharacterBriefFeature.FeatureView(
      state: .preview(hasShimmer: false)
    )
  }
  .frame(maxWidth: .infinity)
}

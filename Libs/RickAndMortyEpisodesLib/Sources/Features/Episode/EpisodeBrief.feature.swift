import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodeBrief feature. Serves as an anchor for project navigation.
enum EpisodeBriefFeature {
  struct FeatureView: View {
    var state: FeatureState

    init(state: FeatureState) {
      self.state = state
    }

    var body: some View {
      VStack {
        HStack {
          Text("\(state.episode.name)")
            .font(.title3)
            .skeletonDecoration(isEnabled: state.isPlaceholder)
          Spacer()
        }
        HStack {
          Text("\(state.episode.episode)")
            .font(.caption)
            .fontDesign(.monospaced)
            .skeletonDecoration(isEnabled: state.isPlaceholder)
          Text("\(BaseEpisodeFeature.formatAirDate(episode: state.episode))")
            .font(.caption)
            .fontDesign(.monospaced)
            .skeletonDecoration(isEnabled: state.isPlaceholder)
          Spacer()
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var episode: EpisodeDomainModel
    var isPlaceholder: Bool

    static func preview(isPlaceholder: Bool) -> Self {
      .init(episode: .dummy, isPlaceholder: isPlaceholder)
    }
  }
}

#Preview {
  VStack {
    EpisodeBriefFeature.FeatureView(
      state: .preview(isPlaceholder: true)
    )
    EpisodeBriefFeature.FeatureView(
      state: .preview(isPlaceholder: false)
    )
  }
  .frame(maxWidth: .infinity)
}

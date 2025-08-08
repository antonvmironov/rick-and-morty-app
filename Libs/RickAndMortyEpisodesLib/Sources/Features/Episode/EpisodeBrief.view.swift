import Foundation
import SharedLib
import SwiftUI

extension EpisodeBriefFeature {
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

  struct FeatureState: Equatable {
    var episode: EpisodeDomainModel
    var isPlaceholder: Bool

    static func preview(isPlaceholder: Bool) -> Self {
      .init(episode: .dummy, isPlaceholder: isPlaceholder)
    }
  }
}

private typealias Subject = EpisodeBriefFeature
#Preview {
  VStack {
    Subject.FeatureView(state: .preview(isPlaceholder: true))
    Subject.FeatureView(state: .preview(isPlaceholder: false))
  }
  .frame(maxWidth: .infinity)
}

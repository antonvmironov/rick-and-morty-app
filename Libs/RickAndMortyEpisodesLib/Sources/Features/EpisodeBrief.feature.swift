import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodeBrief feature. Serves as an anchor for project navigation.
enum EpisodeBriefFeature {
  struct FeatureView: View {
    var episode: EpisodeDomainModel

    init(episode: EpisodeDomainModel) {
      self.episode = episode
    }

    var body: some View {
      VStack {
        HStack {
          Text("\(episode.name)")
            .font(.title3)
          Spacer()
        }
        HStack {
          Text("\(episode.episode)")
            .font(.caption)
            .fontDesign(.monospaced)
          Text("\(BaseEpisodeFeature.formatAirDate(episode: episode))")
            .font(.caption)
            .fontDesign(.monospaced)
          Spacer()
        }
      }
    }
  }
}

#Preview {
  EpisodeBriefFeature.FeatureView(episode: BaseEpisodeFeature.previewEpisode())
}

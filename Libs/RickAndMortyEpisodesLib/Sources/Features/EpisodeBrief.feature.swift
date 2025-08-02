import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodeBrief feature. Serves as an anchor for project navigation.
enum EpisodeBriefFeature {
  static func formatAirDate(episode: EpisodeDomainModel) -> String {
    let inputDateFormatter = DateFormatter()
    inputDateFormatter.dateFormat = "MMMM dd, yyyy"
    let outputDateFormatter = DateFormatter()
    outputDateFormatter.dateFormat = "dd/MM/yyyy"

    let inputValue = episode.airDate
    guard let inputDate = inputDateFormatter.date(from: inputValue)
    else { return inputValue }
    let outputString = outputDateFormatter.string(from: inputDate)
    return outputString
  }

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
          Text("\(EpisodeBriefFeature.formatAirDate(episode: episode))")
            .font(.caption)
            .fontDesign(.monospaced)
          Spacer()
        }
      }
    }
  }
}

#Preview {
  let episode = try! Transformers.loadFixture(
    output: EpisodeDomainModel.self,
    fixtureName: "episode_pilot"
  )
  EpisodeBriefFeature.FeatureView(episode: episode)
}

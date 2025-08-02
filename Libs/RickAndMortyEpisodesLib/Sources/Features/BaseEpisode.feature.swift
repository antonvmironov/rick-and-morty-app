import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodeBrief feature. Serves as an anchor for project navigation.
enum BaseEpisodeFeature {
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

  static func previewEpisode() -> EpisodeDomainModel {
    let episode = try! Transformers.loadFixture(
      output: EpisodeDomainModel.self,
      fixtureName: "episode_pilot"
    )
    return episode
  }
}

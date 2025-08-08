import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the BaseEpisode feature. Serves as an anchor for project navigation.
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
    return .dummy
  }
}

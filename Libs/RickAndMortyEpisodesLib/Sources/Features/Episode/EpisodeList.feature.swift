import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
enum EpisodeListFeature {
  enum Deps {
    typealias Episode = EpisodeDomainModel
    typealias Pagination = ContinuousPaginationFeature<URL, Episode>
    typealias ListItem = EpisodeBriefFeature
  }
}

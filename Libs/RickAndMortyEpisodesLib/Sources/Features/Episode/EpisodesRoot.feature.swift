import Foundation

/// Namespace for the EpisodesRoot feature. Serves as an anchor for project navigation.
enum EpisodesRootFeature {
  enum Deps {
    typealias Episode = EpisodeDomainModel
    typealias Pagination = ContinuousPaginationFeature<URL, Episode>
    typealias EpisodeBrief = EpisodeBriefFeature
    typealias EpisodeList = EpisodeListFeature
    typealias EpisodeDetails = EpisodeDetailsFeature
  }
}

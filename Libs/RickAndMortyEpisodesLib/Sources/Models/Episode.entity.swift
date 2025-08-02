import Foundation
import SharedLib

typealias EpisodeID = Int

/// A domain model of "episode" entity in "RickAndMorty" domain.
struct EpisodeDomainModel: Sendable,
  Codable,
  Equatable,
  Identifiable
{
  let id: EpisodeID
  let name: String
  let airDate: String
  let episode: String
  let characters: [URL]
  let url: URL
  let created: Date

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case airDate = "air_date"
    case episode
    case characters
    case url
    case created
  }

  static let dummy: Self = Transformers.fromAssetCatalog(
    assetName: "episode_dummy",
    bundle: .module
  )
}

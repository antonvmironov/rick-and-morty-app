import Foundation
import SharedLib

typealias CharacterID = Int

/// A domain model of "character" entity in "RickAndMorty" domain.
struct CharacterDomainModel: Sendable,
  Codable,
  Equatable,
  Identifiable
{
  let id: CharacterID
  let name: String
  let status: CharacterStatus
  let species: CharacterSpecies
  let type: String
  let gender: String
  let origin: CharacterLocation
  let location: CharacterLocation
  let image: URL
  let episode: [URL]
  let url: URL
  let created: Date

  static let dummy: Self = Transformers.fromAssetCatalog(
    assetName: "character_dummy",
    bundle: .module
  )
}

// Helper struct for origin and location fields
struct CharacterLocation: Codable, Equatable, Sendable {
  let name: String
  let url: URL?

  init(name: String, url: URL) {
    self.name = name
    self.url = url
  }

  private enum CodingKeys: String, CodingKey {
    case name
    case url
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.url = try? container.decodeIfPresent(URL.self, forKey: .url)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encodeIfPresent(url, forKey: .url)
  }
}

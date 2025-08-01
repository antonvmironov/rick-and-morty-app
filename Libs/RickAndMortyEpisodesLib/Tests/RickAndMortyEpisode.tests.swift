import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("RickAndMortyEpisodeDomainModel Codable conformance")
func RickAndMortyEpisodeDomainModel_Codable_conformance() throws {
  let episode = RickAndMortyEpisodeDomainModel(
    id: pilotEpisodeID,
    name: pilotEpisodeName,
    airDate: pilotEpisodeAirDate,
    episode: pilotEpisodeCode,
    characters: pilotEpisodeCharacters,
    url: pilotEpisodeURL,
    created: pilotEpisodeCreatedDate
  )
  try TestUtils.expectEqualityAfterCodableRoundTrip(episode)
}

@Test("RickAndMortyEpisodeDomainModel Equatable conformance")
func RickAndMortyEpisodeDomainModel_Equatable_conformance() {
  let episode1 = RickAndMortyEpisodeDomainModel(
    id: pilotEpisodeID,
    name: pilotEpisodeName,
    airDate: pilotEpisodeAirDate,
    episode: pilotEpisodeCode,
    characters: pilotEpisodeCharacters,
    url: pilotEpisodeURL,
    created: pilotEpisodeCreatedDate
  )
  let episode2 = RickAndMortyEpisodeDomainModel(
    id: pilotEpisodeID,
    name: pilotEpisodeName,
    airDate: pilotEpisodeAirDate,
    episode: pilotEpisodeCode,
    characters: pilotEpisodeCharacters,
    url: pilotEpisodeURL,
    created: pilotEpisodeCreatedDate
  )
  let episode3 = RickAndMortyEpisodeDomainModel(
    id: 2,
    name: "Lawnmower Dog",
    airDate: "December 9, 2013",
    episode: "S01E02",
    characters: [],
    url: URL(string: "https://rickandmortyapi.com/api/episode/2")!,
    created: pilotEpisodeCreatedDate
  )
  #expect(episode1 == episode2)
  #expect(episode1 != episode3)
}

@Test(
  "RickAndMortyEpisodeDomainModel decodes episode_pilot.json fixture correctly"
)
func RickAndMortyEpisodeDomainModel_decodes_fixture_correctly() throws {
  let url = Bundle.module.url(
    forResource: "episode_pilot",
    withExtension: "json"
  )!
  let data = try Data(contentsOf: url)
  let decoder = RickAndMortyCodable.jsonDecoder()
  let episode = try decoder.decode(
    RickAndMortyEpisodeDomainModel.self,
    from: data
  )

  #expect(episode.id == 1)
  #expect(episode.name == "Pilot")
  #expect(episode.airDate == "December 2, 2013")
  #expect(episode.episode == "S01E01")
  #expect(episode.characters.count == 19)
  #expect(
    episode.characters.first
      == URL(string: "https://rickandmortyapi.com/api/character/1")
  )
  #expect(
    episode.characters.last
      == URL(string: "https://rickandmortyapi.com/api/character/435")
  )
  #expect(
    episode.url == URL(string: "https://rickandmortyapi.com/api/episode/1")
  )
  #expect(
    Calendar.current.isDate(
      episode.created,
      equalTo: pilotEpisodeCreatedDate,
      toGranularity: .second
    )
  )
}

// MARK: - Test Constants

private let pilotEpisodeID = 1
private let pilotEpisodeName = "Pilot"
private let pilotEpisodeAirDate = "December 2, 2013"
private let pilotEpisodeCode = "S01E01"
private let pilotEpisodeCharacters: [URL] = [
  URL(string: "https://rickandmortyapi.com/api/character/1")!,
  URL(string: "https://rickandmortyapi.com/api/character/2")!,
]
private let pilotEpisodeURL = URL(
  string: "https://rickandmortyapi.com/api/episode/1"
)!
private let pilotEpisodeCreatedDate = dateFromString(
  "2017-11-10T12:56:33.798Z"
)

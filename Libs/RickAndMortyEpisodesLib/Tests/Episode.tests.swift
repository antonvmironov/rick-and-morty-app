import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("EpisodeDomainModel Codable conformance")
func EpisodeDomainModel_Codable_conformance() throws {
  let episode = EpisodeDomainModel(
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

@Test("EpisodeDomainModel Equatable conformance")
func EpisodeDomainModel_Equatable_conformance() {
  let episode1 = EpisodeDomainModel(
    id: pilotEpisodeID,
    name: pilotEpisodeName,
    airDate: pilotEpisodeAirDate,
    episode: pilotEpisodeCode,
    characters: pilotEpisodeCharacters,
    url: pilotEpisodeURL,
    created: pilotEpisodeCreatedDate
  )
  let episode2 = EpisodeDomainModel(
    id: pilotEpisodeID,
    name: pilotEpisodeName,
    airDate: pilotEpisodeAirDate,
    episode: pilotEpisodeCode,
    characters: pilotEpisodeCharacters,
    url: pilotEpisodeURL,
    created: pilotEpisodeCreatedDate
  )
  let episode3 = EpisodeDomainModel(
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
  "EpisodeDomainModel decodes episode_pilot.json fixture correctly"
)
func EpisodeDomainModel_decodes_fixture_correctly() throws {
  let url = Bundle.module.url(
    forResource: "episode_pilot",
    withExtension: "json"
  )!
  let data = try Data(contentsOf: url)
  let decoder = Transformers.jsonDecoder()
  let episode = try decoder.decode(
    EpisodeDomainModel.self,
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

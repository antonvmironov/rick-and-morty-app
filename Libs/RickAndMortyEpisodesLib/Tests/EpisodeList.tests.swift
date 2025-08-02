import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("EpisodeListFeature.formatAirDate formats air date correctly")
func EpisodeListFeature_formatAirDate_formats_correctly() {
  let episode = EpisodeDomainModel(
    id: 1,
    name: "Pilot",
    airDate: "December 02, 2013",
    episode: "S01E01",
    characters: [],
    url: URL(string: "https://rickandmortyapi.com/api/episode/1")!,
    created: TestUtils.dateFromString("2017-11-10T12:56:33.000Z")
  )
  let formatted = EpisodeListFeature.formatAirDate(episode: episode)
  #expect(formatted == "02/12/2013")
}

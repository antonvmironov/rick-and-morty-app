import Foundation
import SharedLib
import Testing

@testable import RickAndMortyEpisodesLib

@Test("CharacterDomainModel Codable conformance")
func CharacterDomainModel_Codable_conformance() throws {
  let character = CharacterDomainModel(
    id: rickID,
    name: rickName,
    status: .alive,
    species: .human,
    type: "",
    gender: "Male",
    origin: rickOrigin,
    location: rickLocation,
    image: rickImageURL,
    episode: [episode1URL],
    url: rickURL,
    created: rickCreatedDate
  )
  try TestUtils.expectEqualityAfterCodableRoundTrip(character)
}

@Test("Location Codable conformance")
func Location_Codable_conformance() throws {
  let location = CharacterLocation(
    name: earthName,
    url: earthLocation1URL
  )
  try TestUtils.expectEqualityAfterCodableRoundTrip(location)
}

@Test("CharacterDomainModel Equatable conformance")
func CharacterDomainModel_Equatable_conformance() {
  let character1 = CharacterDomainModel(
    id: rickID,
    name: rickName,
    status: .alive,
    species: .human,
    type: "",
    gender: "Male",
    origin: rickOrigin,
    location: rickLocation,
    image: rickImageURL,
    episode: [episode1URL],
    url: rickURL,
    created: rickCreatedDate
  )
  let character2 = CharacterDomainModel(
    id: rickID,
    name: rickName,
    status: .alive,
    species: .human,
    type: "",
    gender: "Male",
    origin: rickOrigin,
    location: rickLocation,
    image: rickImageURL,
    episode: [episode1URL],
    url: rickURL,
    created: rickCreatedDate
  )
  let character3 = CharacterDomainModel(
    id: mortyID,
    name: mortyName,
    status: .alive,
    species: .human,
    type: "",
    gender: "Male",
    origin: rickOrigin,
    location: rickLocation,
    image: mortyImageURL,
    episode: [episode1URL],
    url: mortyURL,
    created: rickCreatedDate
  )
  #expect(character1 == character2)
  #expect(character1 != character3)
}

@Test("Location Equatable conformance")
func Location_Equatable_conformance() {
  let location1 = CharacterLocation(name: earthName, url: earthLocation1URL)
  let location2 = CharacterLocation(name: earthName, url: earthLocation1URL)
  let location3 = CharacterLocation(name: marsName, url: marsLocation2URL)
  #expect(location1 == location2)
  #expect(location1 != location3)
}

// MARK: - Test Constants

@Test(
  "CharacterDomainModel decodes character_rick.json fixture correctly"
)
func CharacterDomainModel_decodes_fixture_correctly() throws {
  let url = Bundle.module.url(
    forResource: "character_rick",
    withExtension: "json"
  )!
  let data = try Data(contentsOf: url)
  let decoder = Transformers.jsonDecoder()
  let character = try decoder.decode(
    CharacterDomainModel.self,
    from: data
  )

  #expect(character.id == 1)
  #expect(character.name == "Rick Sanchez")
  #expect(character.status == .alive)
  #expect(character.species == .human)
  #expect(character.type == "")
  #expect(character.gender == "Male")
  #expect(character.origin.name == "Earth (C-137)")
  #expect(character.origin.url == earthLocation1URL)
  #expect(character.location.name == "Citadel of Ricks")
  #expect(
    character.location.url
      == URL(string: "https://rickandmortyapi.com/api/location/3")
  )
  #expect(character.image == rickImageURL)
  #expect(character.episode.count == 51)
  #expect(character.episode.first == episode1URL)
  #expect(
    character.episode.last
      == URL(string: "https://rickandmortyapi.com/api/episode/51")
  )
  #expect(character.url == rickURL)
  #expect(
    Calendar.current.isDate(
      character.created,
      equalTo: rickCreatedDate,
      toGranularity: .second
    )
  )
}

private let rickID = 1
private let mortyID = 2
private let rickName = "Rick Sanchez"
private let mortyName = "Morty Smith"
private let earthName = "Earth"
private let marsName = "Mars"
private let rickOrigin = CharacterLocation(
  name: earthName,
  url: earthLocation1URL
)
private let rickLocation = CharacterLocation(
  name: earthName,
  url: earthLocation20URL
)
private let rickImageURL = URL(
  string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
)!
private let mortyImageURL = URL(
  string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg"
)!
private let episode1URL = URL(
  string: "https://rickandmortyapi.com/api/episode/1"
)!
private let rickURL = URL(
  string: "https://rickandmortyapi.com/api/character/1"
)!
private let mortyURL = URL(
  string: "https://rickandmortyapi.com/api/character/2"
)!
private let rickCreatedDate = TestUtils.dateFromString(
  "2017-11-04T18:48:46.250Z"
)
private let earthLocation1URL = URL(
  string: "https://rickandmortyapi.com/api/location/1"
)!
private let earthLocation20URL = URL(
  string: "https://rickandmortyapi.com/api/location/20"
)!
private let marsLocation2URL = URL(
  string: "https://rickandmortyapi.com/api/location/2"
)!

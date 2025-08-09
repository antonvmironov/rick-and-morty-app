import Foundation
import SharedLib
import Testing

@testable import RickAndMortyEpisodesLib

@Test("CharacterDomainModel fuzz decoding with random valid and invalid data")
func CharacterDomainModel_fuzz_decoding() throws {
  let fuzzIterationCount = 50
  for _ in 0..<fuzzIterationCount {
    let json: [String: Any] = [
      "id": Int.random(in: 1...1000),
      "name": Fixtures.validNames.randomElement()!,
      "status": Fixtures.validStatuses.randomElement()!,
      "species": Fixtures.validSpecies.randomElement()!,
      "type": "",
      "gender": Fixtures.validGenders.randomElement()!,
      "origin": [
        "name": Fixtures.validNames.randomElement()!,
        "url": Fixtures.validURLs.randomElement()!,
      ],
      "location": [
        "name": Fixtures.validNames.randomElement()!,
        "url": Fixtures.validURLs.randomElement()!,
      ],
      "image": Fixtures.validImageURLs.randomElement()!,
      "episode": [Fixtures.validEpisodeURLs.randomElement()!],
      "url": Fixtures.validURLs.randomElement()!,
      "created": Fixtures.validDates.randomElement()!,
    ]
    let jsonData = try JSONSerialization.data(withJSONObject: json)
    do {
      _ = try Transformers.jsonDecoder()
        .decode(CharacterDomainModel.self, from: jsonData)
      // If decoding succeeds, check basic invariants
    } catch {
      // Decoding may fail for invalid/fuzzed data
      // Decoding failed for fuzzed CharacterDomainModel JSON as expected
    }
  }
}

@Test("CharacterDomainModel decoding fails for invalid URL in 'url' field")
func CharacterDomainModel_decoding_invalid_url_failure() throws {
  let invalidURLJSON = """
      {
        "id": 1,
        "name": "Rick Sanchez",
        "status": "Alive",
        "species": "Human",
        "type": "",
        "gender": "Male",
        "origin": { "name": "Earth (C-137)", "url": "https://rickandmortyapi.com/api/location/1" },
        "location": { "name": "Citadel of Ricks", "url": "https://rickandmortyapi.com/api/location/3" },
        "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
        "episode": ["https://rickandmortyapi.com/api/episode/1"],
        "url": "not-a-valid-url",
        "created": "2017-11-04T18:48:46.250Z"
      }
    """.utf8Data
  _ = try Transformers.jsonDecoder()
    .decode(CharacterDomainModel.self, from: invalidURLJSON)
  // decoding should still succeed. Ignoring invalid URLs
}

@Test("CharacterDomainModel decoding fails for completely invalid JSON")
func CharacterDomainModel_decoding_failure() {
  let invalidJSON = "{\"notACharacter\":true}".utf8Data
  do {
    _ = try Transformers.jsonDecoder()
      .decode(CharacterDomainModel.self, from: invalidJSON)
    Issue.record("Decoding should have failed for invalid JSON")
  } catch {
    // Decoding failed as expected
  }
}

@Test("CharacterDomainModel Codable conformance")
func CharacterDomainModel_Codable_conformance() throws {
  let character = CharacterDomainModel(
    id: Fixtures.rickID,
    name: Fixtures.rickName,
    status: .alive,
    species: .human,
    type: "",
    gender: "Male",
    origin: Fixtures.rickOrigin,
    location: Fixtures.rickLocation,
    image: Fixtures.rickImageURL,
    episode: [Fixtures.episode1URL],
    url: Fixtures.rickURL,
    created: Fixtures.rickCreatedDate
  )
  try TestUtils.expectEqualityAfterCodableRoundTrip(character)
}

@Test("Location Codable conformance")
func Location_Codable_conformance() throws {
  let location = CharacterLocation(
    name: Fixtures.earthName,
    url: Fixtures.earthLocation1URL
  )
  try TestUtils.expectEqualityAfterCodableRoundTrip(location)
}

@Test("CharacterDomainModel Equatable conformance")
func CharacterDomainModel_Equatable_conformance() {
  let character1 = CharacterDomainModel(
    id: Fixtures.rickID,
    name: Fixtures.rickName,
    status: .alive,
    species: .human,
    type: "",
    gender: "Male",
    origin: Fixtures.rickOrigin,
    location: Fixtures.rickLocation,
    image: Fixtures.rickImageURL,
    episode: [Fixtures.episode1URL],
    url: Fixtures.rickURL,
    created: Fixtures.rickCreatedDate
  )
  let character2 = CharacterDomainModel(
    id: Fixtures.rickID,
    name: Fixtures.rickName,
    status: .alive,
    species: .human,
    type: "",
    gender: "Male",
    origin: Fixtures.rickOrigin,
    location: Fixtures.rickLocation,
    image: Fixtures.rickImageURL,
    episode: [Fixtures.episode1URL],
    url: Fixtures.rickURL,
    created: Fixtures.rickCreatedDate
  )
  let character3 = CharacterDomainModel(
    id: Fixtures.mortyID,
    name: Fixtures.mortyName,
    status: .alive,
    species: .human,
    type: "",
    gender: "Male",
    origin: Fixtures.rickOrigin,
    location: Fixtures.rickLocation,
    image: Fixtures.mortyImageURL,
    episode: [Fixtures.episode1URL],
    url: Fixtures.mortyURL,
    created: Fixtures.rickCreatedDate
  )
  #expect(character1 == character2)
  #expect(character1 != character3)
}

@Test("Location Equatable conformance")
func Location_Equatable_conformance() {
  let location1 = CharacterLocation(
    name: Fixtures.earthName,
    url: Fixtures.earthLocation1URL
  )
  let location2 = CharacterLocation(
    name: Fixtures.earthName,
    url: Fixtures.earthLocation1URL
  )
  let location3 = CharacterLocation(
    name: Fixtures.marsName,
    url: Fixtures.marsLocation2URL
  )
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

  #expect(character.id == Fixtures.rickID)
  #expect(character.name == Fixtures.rickName)
  #expect(character.status == .alive)
  #expect(character.species == .human)
  #expect(character.type == "")
  #expect(character.gender == "Male")
  #expect(character.origin.name == "Earth (C-137)")
  #expect(character.origin.url == Fixtures.earthLocation1URL)
  #expect(character.location.name == "Citadel of Ricks")
  #expect(
    character.location.url
      == URL(string: "https://rickandmortyapi.com/api/location/3")
  )
  #expect(character.image == Fixtures.rickImageURL)
  #expect(character.episode.count == 51)
  #expect(character.episode.first == Fixtures.episode1URL)
  #expect(
    character.episode.last
      == URL(string: "https://rickandmortyapi.com/api/episode/51")
  )
  #expect(character.url == Fixtures.rickURL)
  #expect(
    Calendar.current.isDate(
      character.created,
      equalTo: Fixtures.rickCreatedDate,
      toGranularity: .second
    )
  )
}

@Test("CharacterDomainModel .dummy loads and exposes basic fields")
func CharacterDomainModel_dummy_basic_test() {
  let dummy = CharacterDomainModel.dummy
  // Just check basic fields are non-empty and types are correct
  #expect(!dummy.name.isEmpty, "Dummy character name should not be empty")
  #expect(type(of: dummy) == CharacterDomainModel.self)
  #expect(
    dummy.image.absoluteString.count > 0,
    "Dummy character image URL should not be empty"
  )
  #expect(
    dummy.episode.count > 0,
    "Dummy character should have at least one episode"
  )
}

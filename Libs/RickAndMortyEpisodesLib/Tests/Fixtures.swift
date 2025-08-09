import Foundation

@testable import RickAndMortyEpisodesLib

enum Fixtures {
  static let rickID = 1
  static let mortyID = 2
  static let rickName = "Rick Sanchez"
  static let mortyName = "Morty Smith"
  static let earthName = "Earth"
  static let marsName = "Mars"
  static let rickOrigin = CharacterLocation(
    name: earthName,
    url: earthLocation1URL
  )
  static let rickLocation = CharacterLocation(
    name: earthName,
    url: earthLocation20URL
  )
  static let rickImageURL = URL(
    string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
  )!
  static let mortyImageURL = URL(
    string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg"
  )!
  static let episode1URL = URL(
    string: "https://rickandmortyapi.com/api/episode/1"
  )!
  static let rickURL = URL(
    string: "https://rickandmortyapi.com/api/character/1"
  )!
  static let mortyURL = URL(
    string: "https://rickandmortyapi.com/api/character/2"
  )!
  static let rickCreatedDate = TestUtils.dateFromString(
    "2017-11-04T18:48:46.250Z"
  )
  static let earthLocation1URL = URL(
    string: "https://rickandmortyapi.com/api/location/1"
  )!
  static let earthLocation20URL = URL(
    string: "https://rickandmortyapi.com/api/location/20"
  )!
  static let marsLocation2URL = URL(
    string: "https://rickandmortyapi.com/api/location/2"
  )!

  // Shared test arrays/constants for property-based/fuzz tests
  static let validNames = [
    "Rick Sanchez", "Morty Smith", "Summer Smith", "Beth Smith", "Jerry Smith",
    "Birdperson", "Squanchy", "Mr. Meeseeks", "Unity", "Abradolf Lincler",
  ]
  static let validStatuses = ["Alive", "Dead", "unknown", "Zombie", "Ghost"]
  static let validSpecies = [
    "Human", "Alien", "Humanoid", "Robot", "Cronenberg",
  ]
  static let validGenders = ["Male", "Female", "Genderless", "unknown"]
  static let validURLs = [
    "https://rickandmortyapi.com/api/character/1",
    "https://rickandmortyapi.com/api/character/2",
    "https://rickandmortyapi.com/api/character/3",
    "not-a-valid-url",
    "",
  ]
  static let validImageURLs = [
    "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
    "https://rickandmortyapi.com/api/character/avatar/2.jpeg",
    "not-a-valid-url",
    "",
  ]
  static let validEpisodeURLs = [
    "https://rickandmortyapi.com/api/episode/1",
    "https://rickandmortyapi.com/api/episode/2",
    "not-a-valid-url",
    "",
  ]
  static let validDates = [
    "2017-11-04T18:48:46.250Z",
    "2018-01-10T12:00:00.000Z",
    "not-a-date",
    "",
  ]
}

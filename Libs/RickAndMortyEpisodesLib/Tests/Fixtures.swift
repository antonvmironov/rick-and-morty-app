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
}

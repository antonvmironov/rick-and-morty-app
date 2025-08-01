import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("RickAndMortyCharacterSpecies ExpressibleByStringLiteral")
func RickAndMortyCharacterSpecies_ExpressibleByStringLiteral() {
  let species: RickAndMortyCharacterSpecies = "Alien"
  #expect(species.rawValue == "Alien")
  #expect(species.description == "Alien")
}

@Test("RickAndMortyCharacterSpecies static values")
func RickAndMortyCharacterSpecies_static_values() {
  #expect(RickAndMortyCharacterSpecies.human.rawValue == "Human")
  #expect(RickAndMortyCharacterSpecies.humanoid.rawValue == "Humanoid")
  #expect(RickAndMortyCharacterSpecies.unknown.rawValue == "unknown")
}

@Test("RickAndMortyCharacterSpecies Codable conformance")
func RickAndMortyCharacterSpecies_Codable_conformance() throws {
  let species = RickAndMortyCharacterSpecies(rawValue: "Human")
  try TestUtils.expectEqualityAfterCodableRoundTrip(species)
}

@Test("RickAndMortyCharacterSpecies Equatable conformance")
func RickAndMortyCharacterSpecies_Equatable_conformance() {
  let species1 = RickAndMortyCharacterSpecies(rawValue: "Human")
  let species2 = RickAndMortyCharacterSpecies(rawValue: "Human")
  let species3 = RickAndMortyCharacterSpecies(rawValue: "Humanoid")
  #expect(species1 == species2)
  #expect(species1 != species3)
}

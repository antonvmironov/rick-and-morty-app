import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("CharacterSpecies ExpressibleByStringLiteral")
func CharacterSpecies_ExpressibleByStringLiteral() {
  let species: CharacterSpecies = "Alien"
  #expect(species.rawValue == "Alien")
  #expect(species.description == "Alien")
}

@Test("CharacterSpecies static values")
func CharacterSpecies_static_values() {
  #expect(CharacterSpecies.human.rawValue == "Human")
  #expect(CharacterSpecies.humanoid.rawValue == "Humanoid")
  #expect(CharacterSpecies.unknown.rawValue == "unknown")
}

@Test("CharacterSpecies Codable conformance")
func CharacterSpecies_Codable_conformance() throws {
  let species = CharacterSpecies(rawValue: "Human")
  try TestUtils.expectEqualityAfterCodableRoundTrip(species)
}

@Test("CharacterSpecies Equatable conformance")
func CharacterSpecies_Equatable_conformance() {
  let species1 = CharacterSpecies(rawValue: "Human")
  let species2 = CharacterSpecies(rawValue: "Human")
  let species3 = CharacterSpecies(rawValue: "Humanoid")
  #expect(species1 == species2)
  #expect(species1 != species3)
}

import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("ChracterSpecies ExpressibleByStringLiteral")
func ChracterSpecies_ExpressibleByStringLiteral() {
  let species: ChracterSpecies = "Alien"
  #expect(species.rawValue == "Alien")
  #expect(species.description == "Alien")
}

@Test("ChracterSpecies static values")
func ChracterSpecies_static_values() {
  #expect(ChracterSpecies.human.rawValue == "Human")
  #expect(ChracterSpecies.humanoid.rawValue == "Humanoid")
  #expect(ChracterSpecies.unknown.rawValue == "unknown")
}

@Test("ChracterSpecies Codable conformance")
func ChracterSpecies_Codable_conformance() throws {
  let species = ChracterSpecies(rawValue: "Human")
  try TestUtils.expectEqualityAfterCodableRoundTrip(species)
}

@Test("ChracterSpecies Equatable conformance")
func ChracterSpecies_Equatable_conformance() {
  let species1 = ChracterSpecies(rawValue: "Human")
  let species2 = ChracterSpecies(rawValue: "Human")
  let species3 = ChracterSpecies(rawValue: "Humanoid")
  #expect(species1 == species2)
  #expect(species1 != species3)
}

import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("RickAndMortyCharacterStatus ExpressibleByStringLiteral")
func RickAndMortyCharacterStatus_ExpressibleByStringLiteral() {
  let status: RickAndMortyCharacterStatus = "Zombie"
  #expect(status.rawValue == "Zombie")
  #expect(status.description == "Zombie")
}

@Test("RickAndMortyCharacterStatus static values")
func RickAndMortyCharacterStatus_static_values() {
  #expect(RickAndMortyCharacterStatus.alive.rawValue == "Alive")
  #expect(RickAndMortyCharacterStatus.dead.rawValue == "Dead")
  #expect(RickAndMortyCharacterStatus.unknown.rawValue == "unknown")
}

@Test("RickAndMortyCharacterStatus Codable conformance")
func RickAndMortyCharacterStatus_Codable_conformance() throws {
  let status = RickAndMortyCharacterStatus(rawValue: "Alive")
  try TestUtils.expectEqualityAfterCodableRoundTrip(status)
}

@Test("RickAndMortyCharacterStatus Equatable conformance")
func RickAndMortyCharacterStatus_Equatable_conformance() {
  let status1 = RickAndMortyCharacterStatus(rawValue: "Alive")
  let status2 = RickAndMortyCharacterStatus(rawValue: "Alive")
  let status3 = RickAndMortyCharacterStatus(rawValue: "Dead")
  #expect(status1 == status2)
  #expect(status1 != status3)
}

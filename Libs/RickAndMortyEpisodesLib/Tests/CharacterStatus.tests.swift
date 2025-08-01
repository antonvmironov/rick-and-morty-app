import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("CharacterStatus ExpressibleByStringLiteral")
func CharacterStatus_ExpressibleByStringLiteral() {
  let status: CharacterStatus = "Zombie"
  #expect(status.rawValue == "Zombie")
  #expect(status.description == "Zombie")
}

@Test("CharacterStatus static values")
func CharacterStatus_static_values() {
  #expect(CharacterStatus.alive.rawValue == "Alive")
  #expect(CharacterStatus.dead.rawValue == "Dead")
  #expect(CharacterStatus.unknown.rawValue == "unknown")
}

@Test("CharacterStatus Codable conformance")
func CharacterStatus_Codable_conformance() throws {
  let status = CharacterStatus(rawValue: "Alive")
  try TestUtils.expectEqualityAfterCodableRoundTrip(status)
}

@Test("CharacterStatus Equatable conformance")
func CharacterStatus_Equatable_conformance() {
  let status1 = CharacterStatus(rawValue: "Alive")
  let status2 = CharacterStatus(rawValue: "Alive")
  let status3 = CharacterStatus(rawValue: "Dead")
  #expect(status1 == status2)
  #expect(status1 != status3)
}

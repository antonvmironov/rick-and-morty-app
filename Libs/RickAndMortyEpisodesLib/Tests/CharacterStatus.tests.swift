import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("ChracterStatus ExpressibleByStringLiteral")
func ChracterStatus_ExpressibleByStringLiteral() {
  let status: ChracterStatus = "Zombie"
  #expect(status.rawValue == "Zombie")
  #expect(status.description == "Zombie")
}

@Test("ChracterStatus static values")
func ChracterStatus_static_values() {
  #expect(ChracterStatus.alive.rawValue == "Alive")
  #expect(ChracterStatus.dead.rawValue == "Dead")
  #expect(ChracterStatus.unknown.rawValue == "unknown")
}

@Test("ChracterStatus Codable conformance")
func ChracterStatus_Codable_conformance() throws {
  let status = ChracterStatus(rawValue: "Alive")
  try TestUtils.expectEqualityAfterCodableRoundTrip(status)
}

@Test("ChracterStatus Equatable conformance")
func ChracterStatus_Equatable_conformance() {
  let status1 = ChracterStatus(rawValue: "Alive")
  let status2 = ChracterStatus(rawValue: "Alive")
  let status3 = ChracterStatus(rawValue: "Dead")
  #expect(status1 == status2)
  #expect(status1 != status3)
}

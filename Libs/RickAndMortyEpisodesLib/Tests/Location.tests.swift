import Foundation
import SharedLib
import Testing

@testable import RickAndMortyEpisodesLib

@Test("LocationDomainModel Codable conformance")
func LocationDomainModel_Codable_conformance() throws {
  let location = LocationDomainModel(
    id: earthLocationID,
    name: earthLocationName,
    type: earthLocationType,
    dimension: earthLocationDimension,
    residents: earthLocationResidents,
    url: earthLocationURL,
    created: earthLocationCreatedDate
  )
  try TestUtils.expectEqualityAfterCodableRoundTrip(location)
}

@Test("LocationDomainModel Equatable conformance")
func LocationDomainModel_Equatable_conformance() {
  let location1 = LocationDomainModel(
    id: earthLocationID,
    name: earthLocationName,
    type: earthLocationType,
    dimension: earthLocationDimension,
    residents: earthLocationResidents,
    url: earthLocationURL,
    created: earthLocationCreatedDate
  )
  let location2 = LocationDomainModel(
    id: earthLocationID,
    name: earthLocationName,
    type: earthLocationType,
    dimension: earthLocationDimension,
    residents: earthLocationResidents,
    url: earthLocationURL,
    created: earthLocationCreatedDate
  )
  let location3 = LocationDomainModel(
    id: 2,
    name: "Mars",
    type: "Planet",
    dimension: "Dimension C-137",
    residents: [],
    url: URL(string: "https://rickandmortyapi.com/api/location/2")!,
    created: earthLocationCreatedDate
  )
  #expect(location1 == location2)
  #expect(location1 != location3)
}

@Test(
  "LocationDomainModel decodes location_earth1.json fixture correctly"
)
func LocationDomainModel_decodes_fixture_correctly() throws {
  let url = Bundle.module.url(
    forResource: "location_earth1",
    withExtension: "json"
  )!
  let data = try Data(contentsOf: url)
  let decoder = Transformers.jsonDecoder()
  let location = try decoder.decode(
    LocationDomainModel.self,
    from: data
  )

  #expect(location.id == 1)
  #expect(location.name == "Earth (C-137)")
  #expect(location.type == "Planet")
  #expect(location.dimension == "Dimension C-137")
  #expect(location.residents.count == 27)
  #expect(
    location.residents.first
      == URL(string: "https://rickandmortyapi.com/api/character/38")
  )
  #expect(
    location.residents.last
      == URL(string: "https://rickandmortyapi.com/api/character/394")
  )
  #expect(
    location.url == URL(string: "https://rickandmortyapi.com/api/location/1")
  )
  #expect(
    Calendar.current.isDate(
      location.created,
      equalTo: earthLocationCreatedDate,
      toGranularity: .second
    )
  )
}

// MARK: - Test Constants

private let earthLocationID = 1
private let earthLocationName = "Earth (C-137)"
private let earthLocationType = "Planet"
private let earthLocationDimension = "Dimension C-137"
private let earthLocationResidents: [URL] = [
  URL(string: "https://rickandmortyapi.com/api/character/38")!,
  URL(string: "https://rickandmortyapi.com/api/character/45")!,
]
private let earthLocationURL = URL(
  string: "https://rickandmortyapi.com/api/location/1"
)!
private let earthLocationCreatedDate = TestUtils.dateFromString(
  "2017-11-10T12:42:04.162Z"
)

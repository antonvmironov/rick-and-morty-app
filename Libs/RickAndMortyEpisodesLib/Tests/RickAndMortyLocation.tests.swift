import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("RickAndMortyLocationDomainModel Codable conformance")
func RickAndMortyLocationDomainModel_Codable_conformance() throws {
  let location = RickAndMortyLocationDomainModel(
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

@Test("RickAndMortyLocationDomainModel Equatable conformance")
func RickAndMortyLocationDomainModel_Equatable_conformance() {
  let location1 = RickAndMortyLocationDomainModel(
    id: earthLocationID,
    name: earthLocationName,
    type: earthLocationType,
    dimension: earthLocationDimension,
    residents: earthLocationResidents,
    url: earthLocationURL,
    created: earthLocationCreatedDate
  )
  let location2 = RickAndMortyLocationDomainModel(
    id: earthLocationID,
    name: earthLocationName,
    type: earthLocationType,
    dimension: earthLocationDimension,
    residents: earthLocationResidents,
    url: earthLocationURL,
    created: earthLocationCreatedDate
  )
  let location3 = RickAndMortyLocationDomainModel(
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
  "RickAndMortyLocationDomainModel decodes location_earth1.json fixture correctly"
)
func RickAndMortyLocationDomainModel_decodes_fixture_correctly() throws {
  let url = Bundle.module.url(
    forResource: "location_earth1",
    withExtension: "json"
  )!
  let data = try Data(contentsOf: url)
  let decoder = RickAndMortyCodable.jsonDecoder()
  let location = try decoder.decode(
    RickAndMortyLocationDomainModel.self,
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
private let earthLocationCreatedDate = dateFromString(
  "2017-11-10T12:42:04.162Z"
)

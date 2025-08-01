import Foundation
import Testing

@testable import RickAndMortyEpisodesLib

@Test("RickAndMortyCodable test date formatter")
func RickAndMortyCodable_test_date_formatter() {
  let formatter = RickAndMortyCodable.dateFormatter()
  let acturalDate = formatter.date(from: exampleDateString)
  #expect(acturalDate == expectedDate)
}

@Test("RickAndMortyCodable test json decoder")
func RickAndMortyCodable_test_json_decoder() throws {
  struct DateContainer: Codable {
    var subject: Date
  }
  let decoder = RickAndMortyCodable.jsonDecoder()
  let jsonData = """
    {
      "subject": "\(exampleDateString)"
    }
    """.data(using: .utf8)!
  let container = try decoder.decode(DateContainer.self, from: jsonData)
  #expect(container.subject == expectedDate)
}

func dateFromString(_ string: String) -> Date {
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = [
    .withInternetDateTime,
    .withTimeZone,
    .withFractionalSeconds,
  ]
  if let date = formatter.date(from: string) {
    return date
  } else {
    fatalError(
      "Should never happen in tests. Failed to decode from \(string)"
    )
  }
}

private let expectedDate = Date(timeIntervalSince1970: 1509821326.250)
private let exampleDateString = "2017-11-04T18:48:46.250Z"

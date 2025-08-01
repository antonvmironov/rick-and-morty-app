import Foundation
import Testing

@testable import SharedLib

@Test("Transformers test date formatter")
func Transformers_test_date_formatter() {
  let formatter = Transformers.dateFormatter()
  let actualDate = formatter.date(from: exampleDateString)
  #expect(actualDate == expectedDate)
}

@Test("Transformers test json decoder")
func Transformers_test_json_decoder() throws {
  struct DateContainer: Codable {
    var subject: Date
  }
  let decoder = Transformers.jsonDecoder()
  let jsonData = """
    {
      "subject": "\(exampleDateString)"
    }
    """.data(using: .utf8)!
  let container = try decoder.decode(DateContainer.self, from: jsonData)
  #expect(container.subject == expectedDate)
}

private let expectedDate = Date(timeIntervalSince1970: 1509821326.250)
private let exampleDateString = "2017-11-04T18:48:46.250Z"

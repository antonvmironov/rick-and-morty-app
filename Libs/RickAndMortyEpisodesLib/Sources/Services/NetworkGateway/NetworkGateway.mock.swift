import Foundation
import SharedLib

struct MockNetworkGateway: NetworkGateway {
  static let cachedSinceDate = Date(timeIntervalSinceReferenceDate: 0)

  typealias HandleResponse = @Sendable (URLRequest) throws -> (
    Data,
    URLResponse
  )?
  var jsonDecoder: JSONDecoder
  var handlers: [HandleResponse]

  mutating func expect(
    requestURL: URL,
    statusCode: Int = 200,
    data: Data
  ) {
    let response = HTTPURLResponse(
      url: requestURL,
      statusCode: statusCode,
      httpVersion: "1.1",
      headerFields: [:],
    )!

    handleResponse { request -> (Data, URLResponse)? in
      return request.url == requestURL ? (data, response) : nil
    }
  }

  mutating func handleResponse(
    handleResponse: @escaping HandleResponse
  ) {
    handlers.append(handleResponse)
  }

  static func empty() -> MockNetworkGateway {
    let jsonDecoder = Transformers.jsonDecoder()
    return MockNetworkGateway(
      jsonDecoder: jsonDecoder,
      handlers: []
    )
  }

  func getCached<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>
  ) throws(NetworkError) -> NetworkResponse<Response>? {
    try getFromFixture(operation: operation)
  }

  func get<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>
  ) async throws(NetworkError) -> NetworkResponse<Response> {
    let response = try getFromFixture(operation: operation)
    return response
  }

  private func getFromFixture<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>
  ) throws(NetworkError) -> NetworkResponse<Response> {
    // enumerate handlers until one matches the response
    let data: Data
    let urlRequest = operation.urlRequestProvider()
    let urlResponse: URLResponse
    do {
      var completion: (Data, URLResponse)?
      for handler in handlers {
        completion = try handler(urlRequest)
        if completion != nil {
          break
        }
      }
      if let completion = completion {
        (data, urlResponse) = completion
      } else {
        throw NetworkError.nonHTTPResponse
      }
    } catch {
      throw NetworkError.networkFailure(error)
    }

    // cast to HTTP response
    guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
      throw NetworkError.nonHTTPResponse
    }

    // check status code
    guard (200..<300).contains(httpURLResponse.statusCode) else {
      throw NetworkError.unprocessedStatusCode(
        statusCode: httpURLResponse.statusCode,
        data: data
      )
    }

    // output
    do {
      let finalResponse = try operation.decodeResponse(
        NetworkResponse(
          decodedResponse: urlResponse,
          cachedSince: Self.cachedSinceDate
        ),
        data,
        jsonDecoder
      )
      return finalResponse
    } catch {
      throw NetworkError.responseDecodingFailed(error: error, data: data)
    }
  }
}

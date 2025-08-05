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
    guard
      let result = try? getFromFixture(
        request: operation.urlRequestProvider(),
        cacheCategory: operation.cacheCategory,
        output: Response.self
      )
    else {
      return nil
    }
    return NetworkResponse(
      decodedResponse: result.output,
      cachedSince: result.cachedSince,
    )
  }

  func get<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>
  ) async throws(NetworkError) -> NetworkResponse<Response> {
    let result = try getFromFixture(
      request: operation.urlRequestProvider(),
      cacheCategory: operation.cacheCategory,
      output: Response.self
    )
    return NetworkResponse(
      decodedResponse: result.output,
      cachedSince: result.cachedSince,
    )
  }

  private func getFromFixture<Output: Decodable & Sendable>(
    request: URLRequest,
    cacheCategory: URLCacheCategory,
    output: Output.Type
  ) throws(NetworkError) -> (
    output: Output, cachedSince: Date?, response: URLResponse
  ) {
    // enumerate handlers until one matches the response
    let data: Data
    let response: URLResponse
    do {
      var completion: (Data, URLResponse)?
      for handler in handlers {
        completion = try handler(request)
        if completion != nil {
          break
        }
      }
      if let completion = completion {
        (data, response) = completion
      } else {
        throw NetworkError.nonHTTPResponse
      }
    } catch {
      throw NetworkError.networkFailure(error)
    }

    // cast to HTTP response
    guard let httpURLResponse = response as? HTTPURLResponse else {
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
      let output = try jsonDecoder.decode(Output.self, from: data)
      return (output, Self.cachedSinceDate, response)
    } catch {
      throw NetworkError.responseDecodingFailed(error: error, data: data)
    }
  }
}

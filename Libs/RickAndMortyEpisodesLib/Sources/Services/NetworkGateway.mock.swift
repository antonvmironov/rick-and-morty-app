import Foundation

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

  @Sendable
  func get<Output: Decodable & Sendable>(
    request: URLRequest,
    output: Output.Type,
  ) async throws(NetworkError) -> (output: Output, cachedSince: Date?) {
    // receive response
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
      return (output, Self.cachedSinceDate)
    } catch {
      throw NetworkError.responseDecodingFailed(error)
    }
  }
}

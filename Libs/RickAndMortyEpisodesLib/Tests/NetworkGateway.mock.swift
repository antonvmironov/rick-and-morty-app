import Foundation

@testable import RickAndMortyEpisodesLib

struct MockNetworkGateway: NetworkGateway {
  typealias HandleResponse = @Sendable (URLRequest) throws -> (
    Data,
    URLResponse
  )?
  var jsonDecoder: JSONDecoder
  var handlers: [HandleResponse]

  mutating func expect(
    requestURL: URL,
    statusCode: Int = 200,
    jsonFixtureNamed fixtureName: String
  ) throws {
    let url = Bundle.module.url(
      forResource: fixtureName,
      withExtension: "json"
    )!
    let data = try Data(contentsOf: url)
    let response = HTTPURLResponse(
      url: url,
      statusCode: statusCode,
      httpVersion: "3.0",
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

  func expecing(
    requestURL: URL,
    statusCode: Int = 200,
    jsonFixtureNamed fixtureName: String
  ) throws -> Self {
    var new = self
    try new.expect(
      requestURL: requestURL,
      statusCode: statusCode,
      jsonFixtureNamed: fixtureName
    )
    return new
  }

  static func empty() -> MockNetworkGateway {
    let jsonDecoder = Transformers.jsonDecoder()
    return MockNetworkGateway(
      jsonDecoder: jsonDecoder,
      handlers: []
    )
  }

  @Sendable
  func get<Output: Decodable>(
    request: URLRequest,
    output: Output.Type,
  ) async throws(NetworkError) -> Output {
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

    //
    do {
      return try jsonDecoder.decode(Output.self, from: data)
    } catch {
      throw NetworkError.responseDecodingFailed(error)
    }
  }
}

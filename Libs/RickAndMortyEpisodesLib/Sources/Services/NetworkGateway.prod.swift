import Foundation

actor ProdNetworkGateway: NetworkGateway {
  let urlCache: URLCache
  let urlSession: URLSession
  let jsonDecoder: JSONDecoder

  static func build() -> ProdNetworkGateway {
    let urlCache = URLCache(
      memoryCapacity: 5_000_000,
      diskCapacity: 10_000_000,
      diskPath: "rick-and-morty-episodes-cache"
    )
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = urlCache
    let urlSession = URLSession(configuration: configuration)
    let jsonDecoder = Transformers.jsonDecoder()
    return ProdNetworkGateway(
      urlCache: urlCache,
      urlSession: urlSession,
      jsonDecoder: jsonDecoder,
    )
  }

  init(
    urlCache: URLCache,
    urlSession: URLSession,
    jsonDecoder: JSONDecoder
  ) {
    self.urlCache = urlCache
    self.urlSession = urlSession
    self.jsonDecoder = jsonDecoder
  }

  func get<Output: Decodable & Sendable>(
    request: URLRequest,
    output: Output.Type,
  ) async throws(NetworkError) -> Output {
    // receive response
    let data: Data
    let response: URLResponse
    do {
      (data, response) = try await urlSession.data(for: request)
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

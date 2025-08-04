import Foundation
import SharedLib

/// Production implementaiton of ``NetworkGateway``.
actor ProdNetworkGateway: NetworkGateway {
  private let urlCacheFactory: URLCacheFactory
  private let urlSession: URLSession
  private let jsonEncoder: JSONEncoder
  private let jsonDecoder: JSONDecoder

  static func build(
    urlCacheFactory: URLCacheFactory,
  ) -> ProdNetworkGateway {
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = nil
    let urlSession = URLSession(configuration: configuration)
    return ProdNetworkGateway(
      urlCacheFactory: urlCacheFactory,
      urlSession: urlSession,
    )
  }

  private init(
    urlCacheFactory: URLCacheFactory,
    urlSession: URLSession,
  ) {
    self.urlCacheFactory = urlCacheFactory
    self.urlSession = urlSession
    self.jsonDecoder = Transformers.jsonDecoder()
    self.jsonEncoder = Transformers.jsonEncoder()
  }

  func get<Output: Decodable & Sendable>(
    request: URLRequest,
    cacheCategory: URLCacheCategory,
    output: Output.Type,
  ) async throws(NetworkError) -> (output: Output, cachedSince: Date?) {
    // receive response
    let data: Data
    let response: URLResponse
    var cachedSince: Date?
    var storeCachedResponse = false

    let urlCache = urlCacheFactory.cache(category: cacheCategory)
    if let cachedResponse = urlCache.cachedResponse(for: request) {
      let userInfo = cachedResponse.userInfo as? [String: Any]
      cachedSince = userInfo?["received_date"] as? Date
      data = cachedResponse.data
      response = cachedResponse.response
    } else {
      do {
        (data, response) = try await urlSession.data(for: request)
        storeCachedResponse = true
      } catch {
        throw NetworkError.networkFailure(error)
      }
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
      let output = try jsonDecoder.decode(Output.self, from: data)
      if storeCachedResponse {
        var userInfo: [String: Any] = [:]
        userInfo["received_date"] = Date()
        let cachedResponse = CachedURLResponse(
          response: httpURLResponse,
          data: data,
          userInfo: userInfo,
          storagePolicy: .allowed
        )
        urlCache.storeCachedResponse(cachedResponse, for: request)
      }

      return (output, cachedSince)
    } catch {
      throw NetworkError.responseDecodingFailed(error: error, data: data)
    }
  }
}

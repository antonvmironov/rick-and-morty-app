import ComposableArchitecture
import Foundation
import SharedLib

/// Production implementaiton of ``NetworkGateway``.
final class ProdNetworkGateway: NetworkGateway {
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

  func getCached<Output: Decodable & Sendable>(
    request: URLRequest,
    cacheCategory: URLCacheCategory,
    output: Output.Type,
  ) throws(NetworkError) -> (output: Output, cachedSince: Date?)? {
    guard
      let cachedResponse = getCachedResponse(
        request: request,
        cacheCategory: cacheCategory,
        output: output
      )
    else { return nil }
    let (_, data, cachedSince) = cachedResponse
    let output = try decodeResponse(data: data, output: output)
    return (output, cachedSince)
  }

  func get<Output: Decodable & Sendable>(
    request: URLRequest,
    cacheCategory: URLCacheCategory,
    output: Output.Type,
  ) async throws(NetworkError) -> (output: Output, cachedSince: Date?) {
    if let cachedResponse = try getCached(
      request: request,
      cacheCategory: cacheCategory,
      output: output
    ) {
      return cachedResponse
    } else {
      let (data, response) = try await Result { [urlSession] in
        try await urlSession.data(for: request)
      }
      .mapError(NetworkError.networkFailure)
      .get()
      let cachedSince = getCurrentDate()
      try checkAndCache(
        request: request,
        cacheCategory: cacheCategory,
        response: response,
        data: data,
        cachedSince: cachedSince
      )

      let output = try decodeResponse(data: data, output: output)
      return (output, cachedSince)
    }
  }

  private func getCurrentDate() -> Date {
    Date()  // TBD: inject date for test
  }

  private func getCachedResponse<Output: Decodable & Sendable>(
    request: URLRequest,
    cacheCategory: URLCacheCategory,
    output: Output.Type,
  ) -> (response: URLResponse, data: Data, cachedSince: Date?)? {
    let urlCache = urlCacheFactory.cache(category: cacheCategory)
    guard let cachedResponse = urlCache.cachedResponse(for: request) else {
      return nil
    }
    let userInfo = cachedResponse.userInfo as? [String: Any]
    let cachedSince = userInfo?["received_date"] as? Date
    let data = cachedResponse.data
    let response = cachedResponse.response
    return (response, data, cachedSince)
  }

  private func decodeResponse<Output: Decodable & Sendable>(
    data: Data,
    output: Output.Type
  ) throws(NetworkError) -> Output {
    do {
      return try jsonDecoder.decode(output, from: data)
    } catch {
      throw NetworkError.responseDecodingFailed(error: error, data: data)
    }
  }

  private func checkAndCache(
    request: URLRequest,
    cacheCategory: URLCacheCategory,
    response: URLResponse,
    data: Data,
    cachedSince: Date
  ) throws(NetworkError) {
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

    var userInfo: [String: Any] = [:]
    userInfo["received_date"] = cachedSince
    let cachedResponse = CachedURLResponse(
      response: httpURLResponse,
      data: data,
      userInfo: userInfo,
      storagePolicy: .allowed
    )
    let urlCache = urlCacheFactory.cache(category: cacheCategory)
    urlCache.storeCachedResponse(cachedResponse, for: request)
  }
}

import ComposableArchitecture
import Foundation
import SharedLib

/// Production implementation of ``NetworkGateway``.
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

  func getCached<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>
  ) throws(NetworkError) -> NetworkResponse<Response>? {
    let urlRequest = operation.urlRequestProvider()
    guard
      let cachedResponse = getCachedResponse(
        request: urlRequest,
        cacheCategory: operation.cacheCategory,
        output: Response.self
      )
    else { return nil }
    let (urlResponse, data, cachedSince) = cachedResponse
    let networkResponse = NetworkResponse<URLResponse>(
      decodedResponse: urlResponse,
      cachedSince: cachedSince,
    )
    let decodedResponse: NetworkResponse<Response> = try Result {
      return try operation.decodeResponse(networkResponse, data, jsonDecoder)
    }
    .mapError { NetworkError.responseDecodingFailed(error: $0, data: data) }
    .get()
    return decodedResponse
  }

  func get<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>
  ) async throws(NetworkError) -> NetworkResponse<Response> {
    try await get(operation: operation, validateCachedResponse: { _ in true })
  }

  func get<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>,
    validateCachedResponse: (NetworkResponse<Response>) -> Bool
  ) async throws(NetworkError) -> NetworkResponse<Response> {
    if let cachedResponse = try getCached(operation: operation) {
      return cachedResponse
    }

    let urlRequest = operation.urlRequestProvider()
    let (data, urlResponse) = try await Result { [urlSession] in
      try await urlSession.data(for: urlRequest)
    }
    .mapError(NetworkError.networkFailure)
    .get()
    let cachedSince = getCurrentDate()
    try checkAndCache(
      request: urlRequest,
      cacheCategory: operation.cacheCategory,
      response: urlResponse,
      data: data,
      cachedSince: cachedSince
    )

    let networkResponse = NetworkResponse<URLResponse>(
      decodedResponse: urlResponse,
      cachedSince: cachedSince,
    )
    let decodedResponse: NetworkResponse<Response> = try Result {
      return try operation.decodeResponse(networkResponse, data, jsonDecoder)
    }
    .mapError { NetworkError.responseDecodingFailed(error: $0, data: data) }
    .get()
    return decodedResponse
  }

  static private let minRefreshInterval: TimeInterval = 60 * 60  // 1 hour
  @discardableResult
  func refresh<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>
  ) async throws(NetworkError) -> NetworkResponse<Response> {
    try await get(operation: operation) {
      let timeIntervalAgo = ($0.cachedSince ?? .distantPast).timeIntervalSince(
        getCurrentDate()
      )
      return timeIntervalAgo < Self.minRefreshInterval
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

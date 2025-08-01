import Foundation

/// Production implementaiton of ``NetworkGateway``.
actor ProdNetworkGateway: NetworkGateway {
  private let urlCache: URLCache
  private let urlSession: URLSession
  private let jsonDecoder: JSONDecoder
  private let sessionDelegate: SessionDelegate

  static func build() -> ProdNetworkGateway {
    let urlCache = URLCache(
      memoryCapacity: 5_000_000,
      diskCapacity: 10_000_000,
      diskPath: "rick-and-morty-episodes-cache"
    )
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = urlCache
    let sessionDelegate = SessionDelegate()
    let urlSession = URLSession(
      configuration: configuration,
      delegate: sessionDelegate,
      delegateQueue: nil
    )
    let jsonDecoder = Transformers.jsonDecoder()
    return ProdNetworkGateway(
      urlCache: urlCache,
      urlSession: urlSession,
      jsonDecoder: jsonDecoder,
      sessionDelegate: sessionDelegate,
    )
  }

  private init(
    urlCache: URLCache,
    urlSession: URLSession,
    jsonDecoder: JSONDecoder,
    sessionDelegate: SessionDelegate,
  ) {
    self.urlCache = urlCache
    self.urlSession = urlSession
    self.jsonDecoder = jsonDecoder
    self.sessionDelegate = sessionDelegate
  }

  func get<Output: Decodable & Sendable>(
    request: URLRequest,
    output: Output.Type,
  ) async throws(NetworkError) -> (output: Output, cachedSince: Date?) {
    // receive response
    let data: Data
    let response: URLResponse
    var cachedSince: Date?
    var storeCachedResponse = false

    if let cachedResponse = urlCache.cachedResponse(for: request) {
      let userInfo: [String: Any]? = cachedResponse.userInfo as? [String: Any]
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
      throw NetworkError.responseDecodingFailed(error)
    }
  }
}

private final class SessionDelegate: NSObject, URLSessionDataDelegate {
  func urlSession(
    _ session: URLSession,
    dataTask: URLSessionDataTask,
    willCacheResponse proposedResponse: CachedURLResponse
  ) async -> CachedURLResponse? {
    var userInfo: [String: Any] = proposedResponse.userInfo as! [String: Any]
    userInfo["received_date"] = Date()
    return CachedURLResponse(
      response: proposedResponse.response,
      data: proposedResponse.data,
      userInfo: userInfo,
      storagePolicy: .allowed
    )
  }
}

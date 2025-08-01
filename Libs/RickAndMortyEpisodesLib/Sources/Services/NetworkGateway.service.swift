import Foundation

/// Network gateway is an entry point into network.
protocol NetworkGateway: Sendable {
  func get<Output: Decodable & Sendable>(
    request: URLRequest,
    output: Output.Type,
  ) async throws(NetworkError) -> (output: Output, cachedSince: Date?)
}

/// Errors that ``NetworkGateway`` throws.
enum NetworkError: Error {
  case nonHTTPResponse
  case networkFailure(Error)
  case unprocessedStatusCode(statusCode: Int, data: Data)
  case responseDecodingFailed(Error)
}

import ComposableArchitecture
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

enum NetworkGatewayKey: DependencyKey {
  static var liveValue: NetworkGateway { fatalError("unavailable") }
}

extension DependencyValues {
  var networkGateway: NetworkGateway {
    get { self[NetworkGatewayKey.self] }
    set { self[NetworkGatewayKey.self] = newValue }
  }
}

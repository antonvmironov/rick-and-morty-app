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
enum NetworkError: Error, CustomDebugStringConvertible {
  case nonHTTPResponse
  case networkFailure(Error)
  case unprocessedStatusCode(statusCode: Int, data: Data)
  case responseDecodingFailed(error: Error, data: Data?)

  var debugDescription: String {
    switch self {
    case .nonHTTPResponse:
      return "NetworkError.nonHTTPResponse"
    case .networkFailure(let error):
      return "NetworkError.networkFailure: \(error)"
    case .unprocessedStatusCode(let statusCode, let data):
      let dataDesc = String(data: data, encoding: .utf8) ?? "<binary data>"
      return
        "NetworkError.unprocessedStatusCode(statusCode: \(statusCode), data: \(dataDesc))"
    case .responseDecodingFailed(let error, let data):
      let dataDesc =
        data.map { String(data: $0, encoding: .utf8) ?? "<binary data>" }
        ?? "nil"
      return
        "NetworkError.responseDecodingFailed(error: \(error), data: \(dataDesc))"
    }
  }
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

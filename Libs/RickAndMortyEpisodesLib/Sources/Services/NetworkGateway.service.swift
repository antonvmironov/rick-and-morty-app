import Foundation

protocol NetworkGateway: Sendable {
  func get<Output: Decodable>(
    request: URLRequest,
    output: Output.Type,
  ) async throws(NetworkError) -> Output
}

enum NetworkError: Error {
  case nonHTTPResponse
  case networkFailure(Error)
  case unprocessedStatusCode(statusCode: Int, data: Data)
  case responseDecodingFailed(Error)
}

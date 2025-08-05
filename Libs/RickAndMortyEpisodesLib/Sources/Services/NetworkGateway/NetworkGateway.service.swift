import ComposableArchitecture
import Foundation

/// Network gateway is an entry point into network.
protocol NetworkGateway: Sendable {
  func getCached<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>
  ) throws(NetworkError) -> NetworkResponse<Response>?

  func get<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>
  ) async throws(NetworkError) -> NetworkResponse<Response>

  @discardableResult
  func refresh<Response: Codable & Sendable>(
    operation: NetworkOperation<Response>
  ) async throws(NetworkError) -> NetworkResponse<Response>
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

struct NetworkOperation<Response: Codable & Sendable> {
  typealias DecoderBlock = @Sendable (
    NetworkResponse<URLResponse>,
    Data,
    JSONDecoder
  ) throws -> NetworkResponse<Response>
  var cacheCategory: URLCacheCategory
  var urlRequestProvider: @Sendable () -> URLRequest
  var decodeResponse: DecoderBlock = Self.basicDecoder()

  static func basicDecoder(
    response: Response.Type = Response.self
  ) -> DecoderBlock {
    return { response, data, jsonDecoder in
      let decodedResponse = try jsonDecoder.decode(Response.self, from: data)
      return NetworkResponse(
        decodedResponse: decodedResponse,
        cachedSince: response.cachedSince,
      )
    }
  }

  static func convertingDecoder<
    IntermediateProduct: Codable & Sendable
  >(
    response: Response.Type = Response.self,
    intermediateProduct: IntermediateProduct.Type = IntermediateProduct.self,
    convert: @escaping @Sendable (
      NetworkResponse<IntermediateProduct>,
      JSONDecoder
    ) throws -> Response
  ) -> DecoderBlock {
    return { response, data, jsonDecoder in
      let decodedResponse = try jsonDecoder.decode(
        IntermediateProduct.self,
        from: data
      )
      let intermediateResponse = NetworkResponse<IntermediateProduct>(
        decodedResponse: decodedResponse,
        cachedSince: response.cachedSince,
      )

      let finalResponse = try convert(intermediateResponse, jsonDecoder)
      return NetworkResponse<Response>(
        decodedResponse: finalResponse,
        cachedSince: intermediateResponse.cachedSince,
      )
    }
  }
}

struct NetworkResponse<Response: Sendable> {
  var decodedResponse: Response
  var cachedSince: Date?
}

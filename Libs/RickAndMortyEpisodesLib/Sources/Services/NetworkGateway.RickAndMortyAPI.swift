import Foundation

/// This extension contains rick and morty API access.
extension NetworkGateway {
  func getEndpoints(
    apiURL: URL,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) async throws(NetworkError) -> (
    output: EndpointsDomainModel, cachedSince: Date?
  ) {
    let request = URLRequest(
      url: apiURL,
      cachePolicy: cachePolicy
    )
    let output = try await get(
      request: request,
      output: EndpointsDomainModel.self,
    )
    return output
  }
}

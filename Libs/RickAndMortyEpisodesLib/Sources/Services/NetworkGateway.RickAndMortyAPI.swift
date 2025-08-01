import Foundation

/// This extension contains rick and morty API access.
extension NetworkGateway {
  func getEndpoints(apiURL: URL, ignoreCache: Bool) async throws(NetworkError)
    -> EndpointsDomainModel
  {
    let request = URLRequest(
      url: apiURL,
      cachePolicy: ignoreCache
        ? .reloadRevalidatingCacheData : .returnCacheDataElseLoad
    )
    let output = try await get(
      request: request,
      output: EndpointsDomainModel.self,
    )
    return output
  }
}

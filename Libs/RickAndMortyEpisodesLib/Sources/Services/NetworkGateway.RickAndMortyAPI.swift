import Foundation

/// This extension contains rick and morty API access.
extension NetworkGateway {
  func getEndpoints(
    apiURL: URL,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) async throws(NetworkError) -> (
    output: EndpointsDomainModel, cachedSince: Date?
  ) {
    let request = URLRequest(url: apiURL, cachePolicy: cachePolicy)
    let output = try await get(
      request: request,
      output: EndpointsDomainModel.self,
    )
    return output
  }

  func getCharacter(
    endpoints: EndpointsDomainModel,
    id: CharacterID,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) async throws(NetworkError) -> (
    output: CharacterDomainModel, cachedSince: Date?
  ) {
    let url = endpoints.characters.appendingPathComponent("\(id)")
    let request = URLRequest(url: url, cachePolicy: cachePolicy)
    let output = try await get(
      request: request,
      output: CharacterDomainModel.self,
    )
    return output
  }

  func getPageOfCharacters(
    pageURL: URL,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) async throws(NetworkError) -> (
    output: ResponsePage<CharacterDomainModel>, cachedSince: Date?
  ) {
    let request = URLRequest(url: pageURL, cachePolicy: cachePolicy)
    let output = try await get(
      request: request,
      output: ResponsePage<CharacterDomainModel>.self,
    )
    return output
  }
}

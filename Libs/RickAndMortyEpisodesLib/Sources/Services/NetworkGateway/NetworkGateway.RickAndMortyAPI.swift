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
      cacheCategory: .shared,
      output: EndpointsDomainModel.self,
    )
    return output
  }

  func getCachedEndpoints(
    apiURL: URL,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) throws(NetworkError) -> (
    output: EndpointsDomainModel, cachedSince: Date?
  )? {
    let request = URLRequest(url: apiURL, cachePolicy: cachePolicy)
    let output = try getCached(
      request: request,
      cacheCategory: .shared,
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
    return try await getCharacter(url: url, cachePolicy: cachePolicy)
  }

  func getCharacter(
    url: URL,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) async throws(NetworkError) -> (
    output: CharacterDomainModel, cachedSince: Date?
  ) {
    let request = URLRequest(url: url, cachePolicy: cachePolicy)
    let output = try await get(
      request: request,
      cacheCategory: .characters,
      output: CharacterDomainModel.self,
    )
    return output
  }

  func getPageOfCharacters(
    pageURL: URL,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) async throws(NetworkError) -> ResponsePageContainer<CharacterDomainModel> {
    let request = URLRequest(url: pageURL, cachePolicy: cachePolicy)
    let output = try await get(
      request: request,
      cacheCategory: .characters,
      output: ResponsePagePayload<CharacterDomainModel>.self,
    )
    return ResponsePageContainer(
      payload: output.output,
      cachedSince: output.cachedSince,
      pageURL: pageURL,
    )
  }

  func getLocation(
    endpoints: EndpointsDomainModel,
    id: LocationID,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) async throws(NetworkError) -> (
    output: LocationDomainModel, cachedSince: Date?
  ) {
    let url = endpoints.locations.appendingPathComponent("\(id)")
    let request = URLRequest(url: url, cachePolicy: cachePolicy)
    let output = try await get(
      request: request,
      cacheCategory: .locations,
      output: LocationDomainModel.self,
    )
    return output
  }

  func getPageOfLocations(
    pageURL: URL,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) async throws(NetworkError) -> ResponsePageContainer<LocationDomainModel> {
    let request = URLRequest(url: pageURL, cachePolicy: cachePolicy)
    let output = try await get(
      request: request,
      cacheCategory: .locations,
      output: ResponsePagePayload<LocationDomainModel>.self,
    )
    return ResponsePageContainer(
      payload: output.output,
      cachedSince: output.cachedSince,
      pageURL: pageURL,
    )
  }

  func getEpisode(
    endpoints: EndpointsDomainModel,
    id: EpisodeID,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) async throws(NetworkError) -> (
    output: EpisodeDomainModel, cachedSince: Date?
  ) {
    let url = endpoints.episodes.appendingPathComponent("\(id)")
    let request = URLRequest(url: url, cachePolicy: cachePolicy)
    let output = try await get(
      request: request,
      cacheCategory: .episodes,
      output: EpisodeDomainModel.self,
    )
    return output
  }

  func getPageOfEpisodes(
    pageURL: URL,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) async throws(NetworkError) -> ResponsePageContainer<EpisodeDomainModel> {
    let request = URLRequest(url: pageURL, cachePolicy: cachePolicy)
    let output = try await get(
      request: request,
      cacheCategory: .episodes,
      output: ResponsePagePayload<EpisodeDomainModel>.self,
    )
    return ResponsePageContainer(
      payload: output.output,
      cachedSince: output.cachedSince,
      pageURL: pageURL,
    )
  }

  func getPageOfCachedEpisodes(
    pageURL: URL,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  ) throws(NetworkError) -> ResponsePageContainer<EpisodeDomainModel>? {
    let request = URLRequest(url: pageURL, cachePolicy: cachePolicy)
    guard
      let output = try getCached(
        request: request,
        cacheCategory: .episodes,
        output: ResponsePagePayload<EpisodeDomainModel>.self,
      )
    else { return nil }
    return ResponsePageContainer(
      payload: output.output,
      cachedSince: output.cachedSince,
      pageURL: pageURL,
    )
  }
}

import Foundation

/// This extension contains rick and morty API access.
extension NetworkOperation {

  static func endpoints(
    apiURL: URL,
  ) -> Self where Response == EndpointsDomainModel {
    .init(
      cacheCategory: .shared,
      urlRequestProvider: { URLRequest(url: apiURL) }
    )
  }

  static func character(
    url: URL,
  ) -> Self where Response == CharacterDomainModel {
    .init(
      cacheCategory: .characters,
      urlRequestProvider: { URLRequest(url: url) },
    )
  }

  static func character(
    endpoints: EndpointsDomainModel,
    id: EpisodeID,
  ) -> Self where Response == CharacterDomainModel {
    let url = endpoints.characters.appendingPathComponent("\(id)")
    return character(url: url)
  }

  static func episode(
    url: URL,
  ) -> Self where Response == EpisodeDomainModel {
    .init(
      cacheCategory: .episodes,
      urlRequestProvider: { URLRequest(url: url) },
    )
  }

  static func episode(
    endpoints: EndpointsDomainModel,
    id: EpisodeID,
  ) -> Self where Response == EpisodeDomainModel {
    let url = endpoints.episodes.appendingPathComponent("\(id)")
    return episode(url: url)
  }

  static func location(
    url: URL,
  ) -> Self where Response == LocationDomainModel {
    .init(
      cacheCategory: .locations,
      urlRequestProvider: { URLRequest(url: url) },
    )
  }

  static func location(
    endpoints: EndpointsDomainModel,
    id: LocationID,
  ) -> Self where Response == LocationDomainModel {
    let url = endpoints.episodes.appendingPathComponent("\(id)")
    return location(url: url)
  }

  static func pageOfCharacters(
    pageURL: URL,
  ) -> Self where Response == ResponsePageContainer<CharacterDomainModel> {
    page(
      element: CharacterDomainModel.self,
      pageURL: pageURL,
      cacheCategory: .characters
    )
  }

  static func pageOfEpisodes(
    pageURL: URL,
  ) -> Self where Response == ResponsePageContainer<EpisodeDomainModel> {
    page(
      element: EpisodeDomainModel.self,
      pageURL: pageURL,
      cacheCategory: .episodes
    )
  }

  static func pageOfLocations(
    pageURL: URL,
  ) -> Self where Response == ResponsePageContainer<LocationDomainModel> {
    page(
      element: LocationDomainModel.self,
      pageURL: pageURL,
      cacheCategory: .locations
    )
  }

  private static func page<Element: Sendable & Codable & Equatable>(
    element: Element.Type = Element.self,
    pageURL: URL,
    cacheCategory: URLCacheCategory
  ) -> Self where Response == ResponsePageContainer<Element> {
    .init(
      cacheCategory: cacheCategory,
      urlRequestProvider: { URLRequest(url: pageURL) },
      decodeResponse: Self.convertingDecoder(
        response: Response.self,
        intermediateProduct: ResponsePagePayload<Element>.self,
        convert: { response, _ in
          ResponsePageContainer(
            payload: response.decodedResponse,
            cachedSince: response.cachedSince,
            pageURL: pageURL,
          )
        }
      )
    )
  }
}

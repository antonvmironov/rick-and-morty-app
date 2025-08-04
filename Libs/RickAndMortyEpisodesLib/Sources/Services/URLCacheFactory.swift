import Foundation

final class URLCacheFactory: Sendable {
  private let shared = URLCache.shared
  private let episodes = URLCache(
    memoryCapacity: 5_000_000,
    diskCapacity: 20_000_000
  )
  private let characters = URLCache(
    memoryCapacity: 5_000_000,
    diskCapacity: 20_000_000
  )
  private let locations = URLCache(
    memoryCapacity: 5_000_000,
    diskCapacity: 20_000_000
  )

  func cache(category: URLCacheCategory) -> URLCache {
    switch category {
    case .shared: shared
    case .episodes: episodes
    case .characters: characters
    case .locations: locations
    }
  }

  func clearCache(category: URLCacheCategory) {
    cache(category: category).removeAllCachedResponses()
  }
}

enum URLCacheCategory: Sendable {
  case shared
  case episodes
  case characters
  case locations
}

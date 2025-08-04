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

  func allReports() -> [URLCacheReport] {
    URLCacheCategory.allCases.map(report)
  }

  func report(category: URLCacheCategory) -> URLCacheReport {
    let cache = self.cache(category: category)
    return URLCacheReport(
      category: category,
      memoryCapacity: Int64(cache.memoryCapacity),
      diskCapacity: Int64(cache.diskCapacity),
      currentMemoryUsage: Int64(cache.currentMemoryUsage),
      currentDiskUsage: Int64(cache.currentDiskUsage),
    )
  }
}

enum URLCacheCategory: Sendable, Hashable, CaseIterable {
  case shared
  case episodes
  case characters
  case locations
}

struct URLCacheReport: Sendable, Equatable, Identifiable {
  var id: URLCacheCategory { category }
  var category: URLCacheCategory
  var memoryCapacity: Int64
  var diskCapacity: Int64
  var currentMemoryUsage: Int64
  var currentDiskUsage: Int64
}

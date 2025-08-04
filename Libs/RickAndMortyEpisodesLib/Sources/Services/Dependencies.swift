import ComposableArchitecture
import Foundation
import Kingfisher
import SwiftUI

public final class Dependencies: Sendable {
  let networkGateway: NetworkGateway
  let imageCache: Kingfisher.ImageCache

  init(
    networkGateway: any NetworkGateway,
    imageCache: Kingfisher.ImageCache,
  ) {
    self.networkGateway = networkGateway
    self.imageCache = imageCache
  }

  public static func prod() -> Dependencies {
    return .init(
      networkGateway: ProdNetworkGateway.build(),
      imageCache: ImageCache.default,
    )
  }

  public static func preview() -> Dependencies {
    // keep this force unwrap. its only for SwiftUI preview
    return .init(
      networkGateway: try! MockNetworkGateway.preview(),
      imageCache: ImageCache.default,
    )
  }

  func updateDeps(_ deps: inout DependencyValues) {
    deps.networkGateway = networkGateway
  }
}

enum NetworkGatewayKey: DependencyKey {
  static var liveValue: NetworkGateway { fatalError("unavailable") }
}

enum ImageCacheKey: DependencyKey {
  static var liveValue: Kingfisher.ImageCache { .default }
}

extension DependencyValues {
  var networkGateway: NetworkGateway {
    get { self[NetworkGatewayKey.self] }
    set { self[NetworkGatewayKey.self] = newValue }
  }

  var imageCache: Kingfisher.ImageCache {
    get { self[ImageCacheKey.self] }
    set { self[ImageCacheKey.self] = newValue }
  }
}

import ComposableArchitecture
import Foundation
import Kingfisher
import SwiftUI

public final class Dependencies: Sendable {
  let networkGateway: NetworkGateway
  let imageManager: KingfisherManager
  let urlCacheFactory: URLCacheFactory

  init(
    networkGateway: any NetworkGateway,
    imageManager: KingfisherManager,
    urlCacheFactory: URLCacheFactory,
  ) {
    self.networkGateway = networkGateway
    self.imageManager = imageManager
    self.urlCacheFactory = urlCacheFactory
  }

  public static func prod() -> Dependencies {
    let urlCacheFactory = URLCacheFactory()
    return .init(
      networkGateway:
        ProdNetworkGateway
        .build(urlCacheFactory: urlCacheFactory),
      imageManager: .shared,
      urlCacheFactory: urlCacheFactory
    )
  }

  public static func preview() -> Dependencies {
    // keep this force unwrap. its only for SwiftUI preview
    return .init(
      networkGateway: try! MockNetworkGateway.preview(),
      imageManager: .shared,
      urlCacheFactory: URLCacheFactory(),
    )
  }

  func updateDeps(_ deps: inout DependencyValues) {
    deps.networkGateway = networkGateway
    deps.imageManager = imageManager
    deps.urlCacheFactory = urlCacheFactory
  }
}

enum NetworkGatewayKey: DependencyKey {
  static var liveValue: NetworkGateway { fatalError("unavailable") }
}

enum ImageManagerKey: DependencyKey {
  static var liveValue: KingfisherManager { .shared }
}

extension URLCacheFactory: DependencyKey {
  static var liveValue: URLCacheFactory { fatalError("unavailable") }
}

extension DependencyValues {
  var networkGateway: NetworkGateway {
    get { self[NetworkGatewayKey.self] }
    set { self[NetworkGatewayKey.self] = newValue }
  }
  var imageManager: KingfisherManager {
    get { self[ImageManagerKey.self] }
    set { self[ImageManagerKey.self] = newValue }
  }
  var urlCacheFactory: URLCacheFactory {
    get { self[URLCacheFactory.self] }
    set { self[URLCacheFactory.self] = newValue }
  }
}

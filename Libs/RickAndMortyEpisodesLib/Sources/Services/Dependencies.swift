import BackgroundTasks
import ComposableArchitecture
import Foundation
import Kingfisher
import SwiftUI

public final class Dependencies: Sendable {
  let networkGateway: NetworkGateway
  let imageManager: KingfisherManager
  let urlCacheFactory: URLCacheFactory
  let backgroundRefresher: BackgroundRefresher

  init(
    networkGateway: any NetworkGateway,
    imageManager: KingfisherManager,
    urlCacheFactory: URLCacheFactory,
    backgroundRefresher: BackgroundRefresher
  ) {
    self.networkGateway = networkGateway
    self.imageManager = imageManager
    self.urlCacheFactory = urlCacheFactory
    self.backgroundRefresher = backgroundRefresher
  }

  public static func prod() -> Dependencies {
    let urlCacheFactory = URLCacheFactory()
    let networkGateway =
      ProdNetworkGateway
      .build(urlCacheFactory: urlCacheFactory)
    let backgroundRefresher = ProdBackgroundRefresher(
      networkGateway: networkGateway
    )
    let dependencies = Dependencies(
      networkGateway: networkGateway,
      imageManager: .shared,
      urlCacheFactory: urlCacheFactory,
      backgroundRefresher: backgroundRefresher,
    )
    return dependencies
  }

  public static func preview() -> Dependencies {
    // keep this force unwrap. its only for SwiftUI preview
    let networkGateway = try! MockNetworkGateway.preview()
    return .init(
      networkGateway: networkGateway,
      imageManager: .shared,
      urlCacheFactory: URLCacheFactory(),
      backgroundRefresher: MockBackgroundRefresher()
    )
  }

  func updateDeps(_ deps: inout DependencyValues) {
    deps.networkGateway = networkGateway
    deps.imageManager = imageManager
    deps.urlCacheFactory = urlCacheFactory
    deps.backgroundRefresher = backgroundRefresher
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

enum BackgroundRefresherKey: DependencyKey {
  static var liveValue: BackgroundRefresher { fatalError("unavailable") }
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
  var backgroundRefresher: BackgroundRefresher {
    get { self[BackgroundRefresherKey.self] }
    set { self[BackgroundRefresherKey.self] = newValue }
  }
}

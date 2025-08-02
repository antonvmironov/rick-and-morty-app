import ComposableArchitecture
import Foundation
import SwiftUI

public final class Dependencies: Sendable {
  let networkGateway: NetworkGateway

  init(networkGateway: any NetworkGateway) {
    self.networkGateway = networkGateway
  }

  public static func prod() -> Dependencies {
    return .init(networkGateway: ProdNetworkGateway.build())
  }

  public static func preview() -> Dependencies {
    return .init(networkGateway: try! MockNetworkGateway.preview())
  }

  func updateDeps(_ deps: inout DependencyValues) {
    deps.networkGateway = networkGateway
  }
}

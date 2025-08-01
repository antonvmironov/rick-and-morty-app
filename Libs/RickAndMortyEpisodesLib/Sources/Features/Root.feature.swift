import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
public enum RootFeature {
  // constants and shared functions go here

  @MainActor
  public static func rootView(apiURL: URL) -> some View {
    let store = EpisodeListStore.initial(apiURL: apiURL) { deps in
      deps.networkGateway = ProdNetworkGateway.build()
    }
    return RootView(
      episodeListStore: store
    )
  }
}

public struct RootView: View {
  var episodeListStore: EpisodeListStore

  init(episodeListStore: EpisodeListStore) {
    self.episodeListStore = episodeListStore
  }

  public var body: some View {
    EpisodeListView(store: episodeListStore)
  }
}

#Preview {
  RootFeature.rootView(apiURL: MockNetworkGateway.exampleAPIURL)
}

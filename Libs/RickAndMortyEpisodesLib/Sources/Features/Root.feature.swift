import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
public enum RootFeature {
  // constants and shared functions go here

  @MainActor
  public static func rootView() -> some View {
    return RootView(
      episodeListStore: EpisodeListStore.initial()
    )
  }
}

public struct RootView: View {
  @Bindable var episodeListStore: EpisodeListStore

  init(episodeListStore: EpisodeListStore) {
    self.episodeListStore = episodeListStore
  }

  public var body: some View {
    EpisodeListView(store: episodeListStore)
  }
}

#Preview {
  RootFeature.rootView()
}

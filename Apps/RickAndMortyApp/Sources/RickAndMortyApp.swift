import ComposableArchitecture
import FoundationModels
import RickAndMortyEpisodesLib
import SwiftUI

@main struct RickAndMortyApp: App {
  typealias RootView = EpisodeListView
  typealias RootStore = EpisodeListStore

  let store = RootStore.app()
  init() {
  }

  var body: some Scene {
    WindowGroup {
      RootView(store: store)
    }
  }
}

extension RickAndMortyApp.RootStore {
  static func app() -> RickAndMortyApp.RootStore {
    .initial()
  }
}

import ComposableArchitecture
import RickAndMortyEpisodesLib
import SwiftUI

@main struct RickAndMortyApp: App {
  nonisolated static let prodAPIURL = URL(
    string: "https://rickandmortyapi.com/api"
  )!

  var body: some Scene {
    WindowGroup {
      NavigationStack {
        RickAndMortyEpisodesLib.RootFeature.rootView(apiURL: Self.prodAPIURL)
      }
    }
  }
}

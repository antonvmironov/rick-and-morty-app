import RickAndMortyEpisodesLib
import SwiftUI

@main struct RickAndMortyApp: App {
  nonisolated static let prodAPIURL = URL(
    string: "https://rickandmortyapi.com/api"
  )!

  @State
  var opaqueState = RickAndMortyEpisodesLib.RootFeature.OpaqueState.initial(
    apiURL: prodAPIURL
  )

  var body: some Scene {
    WindowGroup {
      NavigationStack {
        RickAndMortyEpisodesLib.RootFeature.rootView(
          opaqueState: opaqueState
        )
      }
    }
  }
}

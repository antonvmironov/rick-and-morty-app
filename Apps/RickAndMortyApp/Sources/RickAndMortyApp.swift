import ComposableArchitecture
import RickAndMortyEpisodesLib
import SwiftUI

@main struct RickAndMortyApp: App {
  var body: some Scene {
    WindowGroup {
      EpisodesLib.RootFeature.rootView()
    }
  }
}

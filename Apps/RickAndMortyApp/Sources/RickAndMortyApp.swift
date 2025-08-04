import RickAndMortyEpisodesLib
import SwiftUI

@main struct RickAndMortyApp: App {
  nonisolated static let prodAPIURL = URL(
    string: "https://rickandmortyapi.com/api"
  )!

  @State
  var dependencies = RickAndMortyEpisodesLib.Dependencies.prod()

  @State
  var isSettingsPresented: Bool = false

  var body: some Scene {
    WindowGroup {
      NavigationStack {
        RickAndMortyEpisodesLib.RootFeature.rootView(
          apiURL: Self.prodAPIURL,
          dependencies: dependencies
        )
        .navigationDestination(isPresented: $isSettingsPresented) {
          SettingsView()
        }
      }
      .overlay(alignment: .topTrailing) {
        Button(
          action: {
            self.isSettingsPresented.toggle()
          },
          label: {
            Label(
              title: {
                Text("SettingsView")
              },
              icon: {
                Image(systemName: "figure.walk")
              }
            ).labelStyle(.iconOnly)
          }
        )
        .buttonStyle(.bordered)
        .accessibilityHidden(true)
      }
    }
  }
}

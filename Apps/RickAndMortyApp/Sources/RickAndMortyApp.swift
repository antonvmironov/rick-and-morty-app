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
        .sheet(isPresented: $isSettingsPresented) {
          NavigationStack {
            SettingsView()
          }
          .overlay(alignment: .topTrailing) {
            toggleSettingsPresentedButton(
              title: "Back",
              iconSystemName: "escape"
            )
          }
        }
      }
      .overlay(alignment: .topTrailing) {
        toggleSettingsPresentedButton(
          title: "Settings",
          iconSystemName: "figure.walk"
        )
      }
    }
  }

  func toggleSettingsPresentedButton(
    title: String,
    iconSystemName: String
  ) -> some View {
    Button(
      action: {
        self.isSettingsPresented.toggle()
      },
      label: {
        Label(
          title: {
            Text("Settings")
          },
          icon: {
            Image(systemName: iconSystemName)
          }
        ).labelStyle(.iconOnly)
      }
    )
    .buttonStyle(.bordered)
    .accessibilityHidden(true)
  }
}

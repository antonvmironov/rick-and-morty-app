import SwiftUI

struct SettingsView: View {
  var body: some View {
    List {
      header
      LabeledContent("Version", value: version)
    }
    .listStyle(.plain)
    .navigationTitle("Settings")
  }

  var version: String {
    (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)
      ?? "unknown"
  }

  var header: some View {
    Section(
      content: {
        Text(
          """
          Good day to you!

          This is a Rick and Morty demo app.
          Built by Anton Myronov
          """
        )
      },
      header: {
        Text("About")
      }
    )
  }
}

#Preview {
  NavigationStack {
    SettingsView()
  }
}

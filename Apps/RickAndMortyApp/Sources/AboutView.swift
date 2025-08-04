import SwiftUI

struct SettingsView: View {
  var body: some View {
    List {
      header
    }
    .listStyle(.plain)
    .navigationTitle("Settings")
  }

  var header: some View {
    VStack {
      Text("Hello, World!")
    }
  }
}

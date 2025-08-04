import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

enum SettingsFeature: Feature {
  @MainActor
  static func previewStore() -> FeatureStore {
    FeatureStore(
      initialState: .init(),
      reducer: { FeatureReducer() }
    )
  }

  struct FeatureView: View {
    @Bindable var store: FeatureStore

    var body: some View {
      List {
        header
        LabeledContent("Version", value: store.version)
      }
      .listStyle(.plain)
      .navigationTitle("Settings")
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

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        default:
          return .none
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var version: String =
      (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)
      ?? "unknown"
  }

  @CasePathable
  enum FeatureAction: Equatable {
    // No actions for now
  }
}

#Preview {
  NavigationStack {
    SettingsFeature.FeatureView(store: SettingsFeature.previewStore())
  }
}

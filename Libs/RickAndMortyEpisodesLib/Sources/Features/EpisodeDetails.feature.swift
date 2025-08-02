import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodeDetails feature. Serves as an anchor for project navigation.
enum EpisodeDetailsFeature {
  typealias FeatureStore = StoreOf<FeatureReducer>
  typealias TestStore = TestStoreOf<FeatureReducer>

  @MainActor
  static func previewStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    return FeatureStore(
      initialState: FeatureState(episode: BaseEpisodeFeature.previewEpisode()),
      reducer: { FeatureReducer() },
      withDependencies: dependencies.updateDeps
    )
  }

  struct FeatureView: View {
    var store: FeatureStore

    init(store: FeatureStore) {
      self.store = store
    }

    var body: some View {
      List {
        Section {
          ForEach(store.episode.characters, id: \.absoluteString) {
            characterURL in
            row(characterURL: characterURL)
          }
        } header: {
          VStack {
            HStack(spacing: UIConstants.space) {
              HStack {
                Text("Episode")
                  .font(.caption)
                Text("\(store.episode.episode)")
                  .font(.caption)
                  .fontDesign(.monospaced)
              }
              .tagDecoration()
              HStack {
                Group {
                  Text(
                    "Aired on \(BaseEpisodeFeature.formatAirDate(episode: store.episode))"
                  )
                  .font(.caption)
                  .fontDesign(.monospaced)
                }
                .tagDecoration()
                Spacer().frame(width: UIConstants.space)
                Spacer()
              }
            }
          }
        }
      }
      .listStyle(.plain)
      .navigationTitle(store.episode.name)
    }

    func row(characterURL: URL) -> some View {
      Button(
        action: {
          // TODO: navigate
        },
        label: {
          HStack {
            Text("character id: \(characterURL.absoluteString)")
            Spacer()
            Image(systemName: "chevron.right")
          }
        }
      )
      .listRowSeparator(.hidden)
      .tag(characterURL.absoluteString)
    }
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction
    var body: some ReducerOf<Self> {
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var episode: EpisodeDomainModel
  }

  enum FeatureAction: Equatable {}
}

#Preview {
  @Previewable @State var store = EpisodeDetailsFeature.previewStore(
    dependencies: .preview()
  )
  NavigationStack {
    EpisodeDetailsFeature.FeatureView(store: store)
  }
}

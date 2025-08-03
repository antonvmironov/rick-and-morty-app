import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodeDetails feature. Serves as an anchor for project navigation.
enum EpisodeDetailsFeature {
  typealias FeatureStore = StoreOf<FeatureReducer>
  typealias TestStore = TestStoreOf<FeatureReducer>
  typealias CharacterFeature = CharacterBriefFeature
  typealias CharacterState = CharacterBriefFeature.FeatureState
  typealias CharacterStatesArray = IdentifiedArrayOf<CharacterState>

  @MainActor
  static func previewStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    return FeatureStore(
      initialState: FeatureState.initial(
        episode: BaseEpisodeFeature.previewEpisode()
      ),
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
          ForEach(
            store.scope(state: \.characters, action: \.characters)
          ) { characterStore in
            row(characterStore: characterStore)
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
      .onAppear {
        store.send(.preload)
      }
    }

    func row(characterStore: CharacterFeature.FeatureStore) -> some View {
      Button(
        action: {
          // TODO: navigate
        },
        label: {
          HStack {
            CharacterFeature.FeatureView(store: characterStore)
            Image(systemName: "chevron.right")
          }
        }
      )
      .listRowSeparator(.hidden)
      .tag(characterStore.state.id)
    }
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction
    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .preload:
          let characterIDsToPreload = state.characters.prefix(20).map(\.id)
          return .run { @MainActor send in
            for id in characterIDsToPreload {
              send(.characters(.element(id: id, action: .loadFirstTime)))
            }
          }
        default:
          return .none
        }
      }
      .forEach(\.characters, action: \.characters) {
        return CharacterFeature.FeatureReducer()
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var episode: EpisodeDomainModel
    var characters: IdentifiedArrayOf<CharacterState>

    static func initial(episode: EpisodeDomainModel) -> Self {
      .init(
        episode: episode,
        characters: CharacterStatesArray(
          uniqueElements: episode.characters.map(CharacterState.initial)
        ),
      )
    }
  }

  @CasePathable
  enum FeatureAction: Equatable {
    case characters(IdentifiedActionOf<CharacterFeature.FeatureReducer>)
    case preload
  }
}

#Preview {
  @Previewable @State var store = EpisodeDetailsFeature.previewStore(
    dependencies: .preview()
  )
  NavigationStack {
    EpisodeDetailsFeature.FeatureView(store: store)
  }
}

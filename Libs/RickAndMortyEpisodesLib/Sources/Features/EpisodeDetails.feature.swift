import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodeDetails feature. Serves as an anchor for project navigation.
enum EpisodeDetailsFeature {
  typealias FeatureStore = StoreOf<FeatureReducer>
  typealias TestStore = TestStoreOf<FeatureReducer>
  typealias CharacterState = CharacterBriefFeature.FeatureState
  typealias CharacterStatesArray = IdentifiedArrayOf<CharacterState>

  @MainActor
  static func previewStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    return FeatureStore(
      initialState: FeatureState.initial(
        episode: BaseEpisodeFeature.previewEpisode(),
        getCachedCharacter: { _ in nil },
      ),
      reducer: { FeatureReducer() },
      withDependencies: dependencies.updateDeps
    )
  }

  struct FeatureView: View {
    @Bindable
    var store: FeatureStore

    @Environment(\.canSendActions)
    var canSendActions: Bool

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
          sectionHeader()
        }
      }
      .listStyle(.plain)
      .navigationTitle(store.episode.name)
      .onAppear {
        if canSendActions {
          store.send(.preloadIfNeeded)
        }
      }
      .navigationDestination(
        item: $store.scope(
          state: \.selectedCharacterID?.value,
          action: \.selectedCharacter
        )
      ) { scope in
        CharacterDetailsFeature.FeatureView(store: scope)
      }
    }

    private func row(
      characterStore: CharacterBriefFeature.FeatureStore
    ) -> some View {
      Button(
        action: {
          store.send(.selectCharacter(characterStore.characterURL))
        },
        label: {
          HStack {
            CharacterBriefFeature.FeatureView(store: characterStore)
            Image(systemName: "chevron.right")
          }
        }
      )
      .listRowSeparator(.hidden)
      .tag(characterStore.state.id)
    }

    private func sectionHeader() -> some View {
      VStack(alignment: .center) {
        HStack(spacing: UIConstants.space) {
          Text("Episode \(store.episode.episode)")
            .font(.caption)
            .tagDecoration()
          Text(
            "Aired on \(BaseEpisodeFeature.formatAirDate(episode: store.episode))"
          )
          .font(.caption)
          .fontDesign(.monospaced)
          .tagDecoration()
        }
        Text("characters in this episode")
          .font(.title3)
      }
      .frame(maxWidth: .infinity)
    }
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction
    var body: some ReducerOf<Self> {
      BindingReducer()
      coordinatingReducer
      charactersReducer
      selectedCharacterReducer
    }

    var coordinatingReducer: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .preloadIfNeeded:
          guard !state.didPreload else { return .none }
          state.didPreload = true
          let characterIDsToPreload = state.characters.prefix(20)
            .map {
              Effect.send(
                Action.characters(.element(id: $0.id, action: .preloadIfNeeded))
              )
            }
          return .merge(characterIDsToPreload)
        case .selectCharacter(let characterID):
          state.selectedCharacterID =
            characterID
            .flatMap(state.characters.index(id:))
            .map {
              Identified(
                CharacterDetailsFeature.FeatureState(
                  character: state.characters[$0]
                ),
                id: \.character.id
              )
            }
          return .none
        default:
          return .none
        }
      }
    }

    var charactersReducer: some ReducerOf<Self> {
      EmptyReducer()
        .forEach(\.characters, action: \.characters) {
          CharacterBriefFeature.FeatureReducer()
        }
    }

    var selectedCharacterReducer: some ReducerOf<Self> {
      EmptyReducer()
        .ifLet(\.$selectedCharacterID, action: \.selectedCharacter) {
          Scope(state: \.value, action: \.self) {
            CharacterDetailsFeature.FeatureReducer()
          }
        }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var episode: EpisodeDomainModel
    var characters: CharacterStatesArray
    var didPreload = false
    @Presents
    var selectedCharacterID:
      Identified<CharacterState.ID, CharacterDetailsFeature.FeatureState>?

    static func initial(
      episode: EpisodeDomainModel,
      getCachedCharacter: (URL) -> CharacterDomainModel?
    ) -> Self {
      .init(
        episode: episode,
        characters: CharacterStatesArray(
          uniqueElements: episode.characters.map { url in
            let cachedCharacter = getCachedCharacter(url)
            let state = CharacterState.initial(
              characterURL: url,
              cachedCharacter: cachedCharacter
            )
            return state
          }
        ),
      )
    }
  }

  @CasePathable
  enum FeatureAction: Equatable, BindableAction {
    case selectedCharacter(
      PresentationAction<CharacterDetailsFeature.FeatureAction>
    )
    case characters(IdentifiedActionOf<CharacterBriefFeature.FeatureReducer>)
    case preloadIfNeeded
    case selectCharacter(CharacterState.ID?)
    case binding(BindingAction<FeatureState>)
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

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
    @Bindable
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
          sectionHeader()
        }
      }
      .listStyle(.plain)
      .navigationTitle(store.episode.name)
      .onAppear {
        store.send(.preload)
      }
      .navigationDestination(
        item:
          $store
          .scope(
            state: \.selectedCharacterID?.value,
            action: \.selectedCharacter
          )
      ) { scope in
        CharacterDetailsFeature.FeatureView(store: scope)
      }
    }

    private func row(
      characterStore: CharacterFeature.FeatureStore
    ) -> some View {
      Button(
        action: {
          store.send(.selectCharacter(characterStore.characterURL))
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
      EmptyReducer()
        .forEach(\.characters, action: \.characters) {
          CharacterFeature.FeatureReducer()
        }
      EmptyReducer()
        .ifLet(\.$selectedCharacterID, action: \.selectedCharacter) {
          Scope(state: \.value, action: \.self) {
            CharacterDetailsFeature.FeatureReducer()
          }
        }
    }

    var coordinatingReducer: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .preload:
          let characterIDsToPreload = state.characters.prefix(20).map(\.id)
          return .run { @MainActor send in
            for id in characterIDsToPreload {
              send(.characters(.element(id: id, action: .loadFirstTime)))
            }
          }
        case .selectCharacter(let characterID):
          state.selectedCharacterID =
            characterID
            .flatMap(state.characters.index(id:))
            .map { Identified(state.characters[$0], id: \.id) }
          return .none
        default:
          return .none
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var episode: EpisodeDomainModel
    var characters: IdentifiedArrayOf<CharacterState>
    @Presents
    var selectedCharacterID: Identified<CharacterState.ID, CharacterState>?

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
  enum FeatureAction: Equatable, BindableAction {
    case selectedCharacter(PresentationAction<CharacterFeature.FeatureAction>)
    case characters(IdentifiedActionOf<CharacterFeature.FeatureReducer>)
    case preload
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

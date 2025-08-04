import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodeDetails feature. Serves as an anchor for project navigation.
enum EpisodeDetailsFeature: Feature {
  typealias CharacterState = CharacterBriefFeature.FeatureState
  typealias CharacterStatesArray = IdentifiedArrayOf<CharacterState>

  enum A11yIDs: A11yIDProvider {
    case characterRow(id: String)
    var a11yID: String {
      switch self {
      case .characterRow(let id): "character-row-\(id)"
      }
    }
  }

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
        isPresented: $store.isCharacterDetailsPresented
      ) {
        if let store = store.scope(
          state: \.selectedCharacter,
          action: \.selectedCharacter
        ) {
          CharacterDetailsFeature.FeatureView(store: store)
        } else {
          Text("Unable to load character details. Please try again later.")
        }
      }
    }

    private func row(
      characterStore: CharacterBriefFeature.FeatureStore
    ) -> some View {
      Button(
        action: {
          store.send(.presentCharacter(characterStore.characterURL))
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
      .a11yID(A11yIDs.characterRow(id: characterStore.state.characterIDString))
      .accessibilityElement(children: .ignore)
      .accessibilityAction {
        store.send(.presentCharacter(characterStore.characterURL))
      }
      .accessibilityLabel("Character \(characterStore.displayCharacter.name)")
      .accessibilityAddTraits(.isButton)
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
          let characterIDsToPreload = state.characters.prefix(20)
            .map {
              Effect.send(
                Action.characters(.element(id: $0.id, action: .preloadIfNeeded))
              )
            }
          return .merge(characterIDsToPreload)
        case .presentCharacter(let characterID):
          guard let characterID,
            let characterIndex = state.characters.index(id: characterID)
          else {
            state.route = .root
            return .none
          }
          state.route = .characterDetails
          guard state.selectedCharacter?.character.id != characterID else {
            return .none
          }
          state.selectedCharacter = CharacterDetailsFeature.FeatureState(
            character: state.characters[characterIndex]
          )
          return .run { _ in
            await UISelectionFeedbackGenerator().selectionChanged()
          }
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
        .ifLet(\.selectedCharacter, action: \.selectedCharacter) {
          CharacterDetailsFeature.FeatureReducer()
        }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var episode: EpisodeDomainModel
    var characters: CharacterStatesArray
    var route: FeatureRoute
    var selectedCharacter: CharacterDetailsFeature.FeatureState?

    var isCharacterDetailsPresented: Bool {
      get { .characterDetails == route }
      set { route = newValue ? .characterDetails : .root }
    }

    static func initial(
      episode: EpisodeDomainModel,
      getCachedCharacter: (URL) -> CharacterDomainModel?
    ) -> Self {
      let characters = CharacterStatesArray(
        uniqueElements: episode.characters.map { url in
          let cachedCharacter = getCachedCharacter(url)
          let state = CharacterState.initial(
            characterURL: url,
            cachedCharacter: cachedCharacter
          )
          return state
        }
      )
      return initial(episode: episode, characters: characters)
    }

    static func initial(
      episode: EpisodeDomainModel,
      characters: CharacterStatesArray,
    ) -> Self {
      .init(
        episode: episode,
        characters: characters,
        route: .root,
      )
    }
  }

  enum FeatureRoute: Sendable, Hashable {
    case root
    case characterDetails
  }

  @CasePathable
  enum FeatureAction: Equatable, BindableAction {
    case selectedCharacter(CharacterDetailsFeature.FeatureAction)
    case characters(IdentifiedActionOf<CharacterBriefFeature.FeatureReducer>)
    case preloadIfNeeded
    case presentCharacter(CharacterState.ID?)
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

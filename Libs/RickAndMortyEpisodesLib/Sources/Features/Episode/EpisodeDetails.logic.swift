import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

extension EpisodeDetailsFeature {
  final class ProdViewModel: FeatureViewModel {
    typealias CharacterViewModel = CharacterBriefFeature.ProdViewModel
    typealias CharacterDetailsViewModel = CharacterDetailsFeature.ProdViewModel
    private let store: FeatureStore
    init(store: FeatureStore) {
      self.store = store
    }

    var characterViewModels: [CharacterViewModel] {
      store.scope(state: \.characters, action: \.characters).map {
        CharacterViewModel(store: $0)
      }
    }
    var selectedCharacterViewModel: CharacterDetailsViewModel? {
      store.scope(state: \.selectedCharacter, action: \.selectedCharacter).map {
        CharacterDetailsViewModel(store: $0)
      }
    }
    var episode: EpisodeDomainModel { store.episode }
    var isCharacterDetailsPresented: Bool {
      get { store.isCharacterDetailsPresented }
      set { store.isCharacterDetailsPresented = newValue }
    }
    func present(characterURL: URL) {
      store.send(.presentCharacter(characterURL))
    }
    func preloadIfNeeded() {
      store.send(.preloadIfNeeded)
    }
  }

  typealias FeatureStore = StoreOf<FeatureReducer>
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
          guard state.selectedCharacter?.characterBrief.id != characterID else {
            return .none
          }
          state.selectedCharacter = CharacterDetailsFeature.FeatureState(
            characterBrief: state.characters[characterIndex]
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
          BaseCharacterFeature.FeatureReducer()
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
    case characters(IdentifiedActionOf<BaseCharacterFeature.FeatureReducer>)
    case preloadIfNeeded
    case presentCharacter(CharacterState.ID?)
    case binding(BindingAction<FeatureState>)
  }
}

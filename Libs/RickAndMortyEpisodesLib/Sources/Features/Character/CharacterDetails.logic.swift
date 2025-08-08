import ComposableArchitecture
import Foundation
import Kingfisher
import SharedLib

extension CharacterDetailsFeature {
  @Observable final class ProdViewModel: FeatureViewModel {
    private let store: StoreOf<FeatureReducer>

    init(store: StoreOf<FeatureReducer>) {
      self.store = store
    }

    var actualCharacter: Deps.Character? {
      store.characterBrief.characterLoading.status.success
    }
    var placeholderCharacter: Deps.Character {
      store.characterBrief.placeholderCharacter
    }
    var displayCharacter: Deps.Character {
      actualCharacter ?? placeholderCharacter
    }
    var isPlaceholder: Bool {
      store.characterBrief.characterLoading.status.success == nil
    }
    var isShimmering: Bool {
      store.characterBrief.characterLoading.status.isProcessing
    }
    var exported: Deps.Export.TransferableCharacter? {
      store.exported
    }
    func preloadIfNeeded() {
      store.send(.preloadIfNeeded)
    }
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    @Dependency(\.imageManager)
    var imageManager: KingfisherManager

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .preloadIfNeeded:
          if let character = state.characterBrief.actualCharacter {
            state.exported = Deps.Export.TransferableCharacter(
              character: character,
              imageManager: imageManager
            )
          }
          return .send(.characterBrief(.preloadIfNeeded))
        case .characterBrief(
          .characterLoading(.finishProcessing(let character))
        ):
          state.exported = Deps.Export.TransferableCharacter(
            character: character,
            imageManager: imageManager
          )
          return .none
        default:
          return .none
        }
      }
      Scope(state: \.characterBrief, action: \.characterBrief) {
        Deps.Brief.FeatureReducer()
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var characterBrief: Deps.Brief.FeatureState
    var exported: Deps.Export.TransferableCharacter?
  }

  @CasePathable
  enum FeatureAction: Equatable {
    case characterBrief(Deps.Brief.FeatureAction)
    case preloadIfNeeded
  }
}

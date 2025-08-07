import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

extension BaseCharacterFeature {
  typealias FeatureStore = StoreOf<FeatureReducer>
  typealias TestStore = TestStoreOf<FeatureReducer>

  @MainActor
  static func previewPlaceholderStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    let initialState = FeatureState.preview(
      characterURL: MockNetworkGateway.characterFirstAPIURL,
      characterLoading: .initial(cachedSuccess: nil)
    )
    return previewStore(initialState: initialState, dependencies: dependencies)
  }

  @MainActor
  static func previewSuccessStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    let initialState = FeatureState.preview(
      characterURL: MockNetworkGateway.characterFirstAPIURL,
      characterLoading: .success(.dummy)
    )
    return previewStore(initialState: initialState, dependencies: dependencies)
  }

  @MainActor
  static func previewFailureStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    let initialState = FeatureState.preview(
      characterURL: MockNetworkGateway.characterFirstAPIURL,
      characterLoading: .failure("test failure")
    )
    return previewStore(initialState: initialState, dependencies: dependencies)
  }

  @MainActor
  static func previewStore(
    initialState: FeatureState,
    dependencies: Dependencies,
  ) -> FeatureStore {
    return FeatureStore(
      initialState: initialState,
      reducer: { FeatureReducer() },
      withDependencies: dependencies.updateDeps
    )
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    @Dependency(\.networkGateway)
    var networkGateway: NetworkGateway

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .reloadOnFailure:
          if case .idle(_, .some) = state.characterLoading.status {
            return .send(.characterLoading(.process(state.characterURL)))
          } else {
            return .none
          }
        case .preloadIfNeeded:
          if case .idle(.none, .none) = state.characterLoading.status {
            return .send(.characterLoading(.process(state.characterURL)))
          } else {
            return .none
          }
        default:
          return .none
        }
      }
      Scope(
        state: \.characterLoading,
        action: \.characterLoading
      ) { [networkGateway] in
        Deps.CharacterLoading.FeatureReducer { characterURL in
          let operation = NetworkOperation.character(url: characterURL)
          let response = try await networkGateway.get(operation: operation)
          return response.decodedResponse
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable, Identifiable {
    var id: URL { characterURL }
    let characterURL: URL
    let placeholderCharacter: CharacterDomainModel = .dummy
    var characterLoading: Deps.CharacterLoading.FeatureState
    var characterIDString: String { characterURL.lastPathComponent }

    var actualCharacter: CharacterDomainModel? {
      characterLoading.status.success
    }

    var displayCharacter: CharacterDomainModel {
      actualCharacter ?? placeholderCharacter
    }

    var isPlaceholder: Bool {
      characterLoading.status.success == nil
    }

    var isShimmering: Bool {
      characterLoading.status.isProcessing
    }

    static func preview(
      characterURL: URL,
      characterLoading: Deps.CharacterLoading.FeatureState
    ) -> Self {
      .init(characterURL: characterURL, characterLoading: characterLoading)
    }

    static func initial(
      characterURL: URL,
      cachedCharacter: CharacterDomainModel?
    ) -> Self {
      .init(
        characterURL: characterURL,
        characterLoading: .initial(cachedSuccess: cachedCharacter)
      )
    }
  }

  @CasePathable
  enum FeatureAction: Equatable {
    case characterLoading(Deps.CharacterLoading.FeatureAction)
    case preloadIfNeeded
    case reloadOnFailure
  }
}

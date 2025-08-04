import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the BaseCharacter feature. Serves as an anchor for project navigation.
enum BaseCharacterFeature {
  typealias CharacterLoadingFeature = ProcessHostFeature<
    URL, CharacterDomainModel
  >
  typealias FeatureStore = StoreOf<FeatureReducer>
  typealias TestStore = TestStoreOf<FeatureReducer>

  static func previewCharacter() -> CharacterDomainModel {
    return .dummy
  }

  @MainActor
  static func previewPlaceholderStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    let initialState = FeatureState.preview(
      characterURL: MockNetworkGateway.characterFirstAPIURL,
      characterLoading: .initial()
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
      Scope(state: \.characterLoading, action: \.characterLoading) {
        [networkGateway] in
        CharacterLoadingFeature.FeatureReducer { characterURL in
          let response =
            try await networkGateway
            .getCharacter(
              url: characterURL,
              cachePolicy: .returnCacheDataElseLoad
            )
          return response.output
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable, Identifiable {
    var id: URL { characterURL }
    let characterURL: URL
    let placeholderCharacter: CharacterDomainModel = .dummy
    var characterLoading: CharacterLoadingFeature.FeatureState
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
      characterLoading: CharacterLoadingFeature.FeatureState
    ) -> Self {
      .init(characterURL: characterURL, characterLoading: characterLoading)
    }

    static func initial(
      characterURL: URL
    ) -> Self {
      .init(characterURL: characterURL, characterLoading: .init())
    }
  }

  @CasePathable
  enum FeatureAction: Equatable {
    case characterLoading(CharacterLoadingFeature.FeatureAction)
    case preloadIfNeeded
    case reloadOnFailure
  }
}

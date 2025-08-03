import ComposableArchitecture
import Flow
import Foundation
import Kingfisher
import SharedLib
import Shimmer
import SwiftUI

/// Namespace for the CharacterBrief feature. Serves as an anchor for project navigation.
enum CharacterBriefFeature {
  typealias CharacterLoadingFeature = ProcessHostFeature<
    URL, CharacterDomainModel
  >
  typealias FeatureStore = StoreOf<FeatureReducer>

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

  struct FeatureView: View {
    var store: FeatureStore

    init(store: FeatureStore) {
      self.store = store
    }

    var body: some View {
      loadableContent()
        .onAppear {
          if !UIConstants.inPreview {
            store.send(.loadFirstTime)
          }
        }
    }

    private func loadableContent() -> some View {
      return HStack(spacing: UIConstants.space) {
        ZStack {
          if store.characterLoading.status.failureMessage != nil {
            reloadView()
            characterIDView().hidden()
          } else {
            reloadView().hidden()
            characterIDView()
          }
        }
        characterContentView(character: store.displayCharacter)
        Spacer(minLength: 0)
      }
    }

    private func characterIDView() -> some View {
      Text(store.characterURL.lastPathComponent)
        .font(.body)
        .fontDesign(.monospaced)
    }

    private func reloadView() -> some View {
      return Button(
        action: {
          store.send(.reloadOnFailure)
        },
        label: {
          Label(
            title: {
              Text("Retry")
            },
            icon: {
              Image(
                systemName:
                  "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90"
              )
            }
          )
          .labelStyle(.iconOnly)
        }
      )
      .buttonStyle(.bordered)
    }

    private func characterContentView(character: CharacterDomainModel)
      -> some View
    {
      let contentModifier = SkeletonDecorationFeature.FeatureViewModifier(
        isEnabled: store.isPlaceholder,
        isShimmering: store.isShimmering,
      )
      return VStack(alignment: .leading) {
        Text(character.name)
          .font(.headline)
          .modifier(contentModifier)
        HFlow {
          Group {
            Text(character.species.description)
              .modifier(contentModifier)
            if !character.type.isEmpty {
              Text("species: \(character.type)")
                .modifier(contentModifier)
            }
            Text("origin: \(character.origin.name)")
              .modifier(contentModifier)
          }
          .font(.body)
          .tagDecoration()
          Spacer()
        }
      }
    }
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
        case .loadFirstTime:
          if case .idle(.some, .none) = state.characterLoading.status {
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
          try await networkGateway
            .getCharacter(
              url: characterURL,
              cachePolicy: .returnCacheDataElseLoad
            ).output
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    let characterURL: URL
    let placeholderCharacter: CharacterDomainModel = .dummy
    var characterLoading: CharacterLoadingFeature.FeatureState
    var characterIDString: String { characterURL.lastPathComponent }

    var displayCharacter: CharacterDomainModel {
      characterLoading.status.success
        ?? placeholderCharacter
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
  }

  @CasePathable
  enum FeatureAction: Equatable {
    case characterLoading(CharacterLoadingFeature.FeatureAction)
    case loadFirstTime
    case reloadOnFailure
  }
}

#Preview {
  @Previewable @State var placeholderStore =
    CharacterBriefFeature
    .previewPlaceholderStore(dependencies: .preview())
  @Previewable @State var successStore =
    CharacterBriefFeature
    .previewSuccessStore(dependencies: .preview())
  @Previewable @State var failureStore =
    CharacterBriefFeature
    .previewFailureStore(dependencies: .preview())

  VStack {
    GroupBox("placeholder") {
      CharacterBriefFeature.FeatureView(store: placeholderStore)
    }
    GroupBox("success") {
      CharacterBriefFeature.FeatureView(store: successStore)
    }
    GroupBox("failure") {
      CharacterBriefFeature.FeatureView(store: failureStore)
    }
  }
  .frame(maxWidth: .infinity)
}

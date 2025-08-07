import ComposableArchitecture
import Flow
import Foundation
import Kingfisher
import SharedLib
import Shimmer
import SwiftUI

/// Namespace for the CharacterDetails feature. Serves as an anchor for project navigation.
enum CharacterDetailsFeature: Feature {
  typealias CharacterLoadingFeature = ProcessHostFeature<
    URL, CharacterDomainModel
  >
  typealias Exported = CharacterExportFeature.FeatureState

  enum A11yIDs: String, A11yIDProvider {
    case exportToPDF = "export-to-pdf"
    var a11yID: String { rawValue }
  }

  @MainActor
  static func previewPlaceholderStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    let initialState = BaseCharacterFeature.FeatureState.preview(
      characterURL: MockNetworkGateway.characterFirstAPIURL,
      characterLoading: .initial(cachedSuccess: nil)
    )
    return previewStore(
      initialCharacterState: initialState,
      dependencies: dependencies
    )
  }

  @MainActor
  static func previewSuccessStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    let initialState = BaseCharacterFeature.FeatureState.preview(
      characterURL: MockNetworkGateway.characterFirstAPIURL,
      characterLoading: .success(.dummy)
    )
    return previewStore(
      initialCharacterState: initialState,
      dependencies: dependencies
    )
  }

  @MainActor
  static func previewFailureStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    let initialState = BaseCharacterFeature.FeatureState.preview(
      characterURL: MockNetworkGateway.characterFirstAPIURL,
      characterLoading: .failure("test failure")
    )
    return previewStore(
      initialCharacterState: initialState,
      dependencies: dependencies
    )
  }

  @MainActor
  static func previewStore(
    initialCharacterState: BaseCharacterFeature.FeatureState,
    dependencies: Dependencies,
  ) -> FeatureStore {
    return FeatureStore(
      initialState: .init(character: initialCharacterState),
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
          CharacterProfileFeature.FeatureView(
            actualCharacter: store.character.actualCharacter,
            placeholderCharacter: store.character.placeholderCharacter,
            mode: .uiRendering(
              isPlaceholder: store.character.isPlaceholder,
              isShimmering: store.character.isShimmering
            ),
          )
          if let exported = store.exported {
            VStack(alignment: .center) {
              shareLink(
                exported: exported,
                character: store.character.displayCharacter
              )
            }
            .frame(maxWidth: .infinity)
          }
        } header: {
          VStack(alignment: .center) {
            Text("character profile")
              .font(.title3)
          }
          .frame(maxWidth: .infinity)
        }
        .listRowSeparator(.hidden)
        .listRowSpacing(UIConstants.space * 2)
      }
      .listStyle(.plain)
      .navigationTitle(store.character.displayCharacter.name)
      .onAppear {
        store.send(.preloadIfNeeded)
      }
    }

    private func shareLink(
      exported: Exported,
      character: CharacterDomainModel
    ) -> some View {
      ShareLink(
        item: CharacterExportFeature.transferrable(
          character: character,
          imageManager: .shared
        ),
        preview: SharePreview(
          "\(character.name) - Rick and Morty character",
          image: Image(systemName: "person.fill")
        ),
      ) {
        Label(
          title: {
            Text("Export to PDF")
          },
          icon: {
            Image(systemName: "document.fill")
          }
        )
      }
      .buttonStyle(.bordered)
      .accessibilityElement(children: .ignore)
      .a11yID(A11yIDs.exportToPDF)
      .accessibilityLabel("Export profile of \(character.name) to PDF")
      .accessibilityAddTraits(.isButton)
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
          if let character = state.character.actualCharacter {
            state.exported = Exported(
              character: character,
              imageManager: imageManager
            )
          }
          return .send(.character(.preloadIfNeeded))
        case .character(.characterLoading(.finishProcessing(let character))):
          state.exported = Exported(
            character: character,
            imageManager: imageManager
          )
          return .none
        default:
          return .none
        }
      }
      Scope(state: \.character, action: \.character) {
        BaseCharacterFeature.FeatureReducer()
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var character: BaseCharacterFeature.FeatureState
    var exported: Exported?
  }

  @CasePathable
  enum FeatureAction: Equatable {
    case character(BaseCharacterFeature.FeatureAction)
    case preloadIfNeeded
  }
}

#Preview {
  @Previewable @State var placeholderStore =
    CharacterDetailsFeature
    .previewPlaceholderStore(dependencies: .preview())
  @Previewable @State var successStore =
    CharacterDetailsFeature
    .previewSuccessStore(dependencies: .preview())
  @Previewable @State var failureStore =
    CharacterDetailsFeature
    .previewFailureStore(dependencies: .preview())

  NavigationStack {
    CharacterDetailsFeature.FeatureView(store: successStore)
  }
}

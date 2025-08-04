import ComposableArchitecture
import Flow
import Foundation
import Kingfisher
import SharedLib
import Shimmer
import SwiftUI

/// Namespace for the CharacterDetails feature. Serves as an anchor for project navigation.
enum CharacterDetailsFeature {
  typealias CharacterLoadingFeature = ProcessHostFeature<
    URL, CharacterDomainModel
  >
  typealias FeatureStore = StoreOf<FeatureReducer>
  typealias TestStore = TestStoreOf<FeatureReducer>

  @MainActor
  static func previewPlaceholderStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    let initialState = BaseCharacterFeature.FeatureState.preview(
      characterURL: MockNetworkGateway.characterFirstAPIURL,
      characterLoading: .initial()
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
  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    var body: some ReducerOf<Self> {
      Scope(state: \.character, action: \.character) {
        BaseCharacterFeature.FeatureReducer()
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var character: BaseCharacterFeature.FeatureState
  }

  @CasePathable
  enum FeatureAction: Equatable {
    case character(BaseCharacterFeature.FeatureAction)
    case exportToPDF
  }

  struct FeatureView: View {
    @Bindable
    var store: FeatureStore

    @State
    var isExportingToPDF: Bool = false

    init(store: FeatureStore) {
      self.store = store
    }

    var body: some View {
      List {
        Section {
          CharacterProfileFeature.CharacterProfileView(
            actualCharacter: store.character.actualCharacter,
            placeholderCharacter: store.character.placeholderCharacter,
            mode: .uiRendering(
              isPlaceholder: store.character.isPlaceholder,
              isShimmering: store.character.isShimmering
            ),
          )
          VStack(alignment: .center) {
            shareLink()
          }
          .frame(maxWidth: .infinity)
        } header: {
          sectionHeader()
        }
        .listRowSeparator(.hidden)
        .listRowSpacing(UIConstants.space * 2)
      }
      .listStyle(.plain)
      .navigationTitle(store.character.displayCharacter.name)
      .onAppear {
        if !UIConstants.inPreview {
          store.send(.character(.loadFirstTime))
        }
      }
      .fileExporter(
        isPresented: $isExportingToPDF,
        item:
          CharacterExportFeature
          .transferrable(character: store.character.displayCharacter),
        onCompletion: { result in
          print("expored \(result)")
        }
      )
    }

    private func shareLink() -> some View {
      ShareLink(
        item: CharacterExportFeature.transferrable(
          character: store.character.displayCharacter
        ),
        preview: SharePreview(
          "\(store.character.displayCharacter.name) - Rick and Morty character",
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
    }

    private func sectionHeader() -> some View {
      VStack(alignment: .center) {
        Text("character profile")
          .font(.title3)
      }
      .frame(maxWidth: .infinity)
    }

    private func reloadView() -> some View {
      return Button(
        action: {
          store.send(.character(.reloadOnFailure))
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
          .labelStyle(.titleAndIcon)
        }
      )
      .buttonStyle(.bordered)
    }

    private var loadableContentModifier: some ViewModifier {
      SkeletonDecorationFeature.FeatureViewModifier(
        isEnabled: store.character.isPlaceholder,
        isShimmering: store.character.isShimmering,
      )
    }

    private func characterImagePlaceholder() -> some View {
      RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
        .fill(
          UIConstants.inPreview ? .gray : Color("SecondaryBackground")
        )
        .modifier(loadableContentModifier)
    }
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

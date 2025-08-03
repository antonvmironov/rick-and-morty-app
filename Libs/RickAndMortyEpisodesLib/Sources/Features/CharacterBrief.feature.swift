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
  typealias FeatureStore = BaseCharacterFeature.FeatureStore
  typealias TestStore = BaseCharacterFeature.TestStore
  typealias FeatureReducer = BaseCharacterFeature.FeatureReducer
  typealias FeatureState = BaseCharacterFeature.FeatureState
  typealias FeatureAction = BaseCharacterFeature.FeatureAction

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
}

#Preview {
  @Previewable @State var placeholderStore =
    BaseCharacterFeature
    .previewPlaceholderStore(dependencies: .preview())
  @Previewable @State var successStore =
    BaseCharacterFeature
    .previewSuccessStore(dependencies: .preview())
  @Previewable @State var failureStore =
    BaseCharacterFeature
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

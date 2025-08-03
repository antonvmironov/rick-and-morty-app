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
  typealias FeatureStore = BaseCharacterFeature.FeatureStore
  typealias TestStore = BaseCharacterFeature.TestStore
  typealias FeatureReducer = BaseCharacterFeature.FeatureReducer
  typealias FeatureState = BaseCharacterFeature.FeatureState
  typealias FeatureAction = BaseCharacterFeature.FeatureAction

  struct FeatureView: View {
    @Bindable
    var store: FeatureStore

    init(store: FeatureStore) {
      self.store = store
    }

    var body: some View {
      HStack {
        characterContentView(character: store.displayCharacter)
        Spacer(minLength: 0)
      }
      .onAppear {
        if !UIConstants.inPreview {
          store.send(.loadFirstTime)
        }
      }
    }

    private let characterIDMinWidth = UIConstants.space * 6

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
          .labelStyle(.titleAndIcon)
        }
      )
      .buttonStyle(.bordered)
    }

    private var loadableContentModifier: some ViewModifier {
      SkeletonDecorationFeature.FeatureViewModifier(
        isEnabled: store.isPlaceholder,
        isShimmering: store.isShimmering,
      )
    }

    private func characterContentView(
      character: CharacterDomainModel
    ) -> some View {
      HStack(spacing: UIConstants.space) {
        VStack(alignment: .leading) {
          HStack {
            Text(store.characterIDString)
              .font(.body)
              .fontDesign(.monospaced)
              .padding(UIConstants.space / 2)
              .frame(
                minWidth: characterIDMinWidth,
                alignment: .center
              )
              .cornerRadius(UIConstants.cornerRadius)
              .background(
                RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                  .fill(
                    UIConstants.inPreview ? .gray : Color("SecondaryBackground")
                  )
              )
            Text(character.name)
              .font(.headline)
              .modifier(loadableContentModifier)
          }
          HStack(alignment: .top) {
            if store.characterLoading.status.failureMessage != nil {
              reloadView()
            } else {
              tagView(label: "species", content: character.species.rawValue)
              tagView(label: "origin", content: character.origin.name)
            }
          }
          .lineLimit(1)
        }
        Spacer()
        characterImage()
      }
    }

    private func tagView(
      label: String,
      content: String,
    ) -> some View {
      VStack(alignment: .leading, spacing: UIConstants.space / 2) {
        Text(label)
          .minimumScaleFactor(0.5)
          .font(.caption2)
        Text(content)
          .minimumScaleFactor(0.5)
          .font(.caption)
          .modifier(loadableContentModifier)
      }
    }

    private func characterImagePlaceholder() -> some View {
      RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
        .fill(
          UIConstants.inPreview ? .gray : Color("SecondaryBackground")
        )
        .modifier(loadableContentModifier)
    }

    private func characterImage() -> some View {
      Group {
        if let imageURL = store.characterLoading.status.success?.image {
          KFImage
            .url(imageURL)
            .placeholder { _ in
              characterImagePlaceholder()
                .skeletonDecoration(isEnabled: true, isShimmering: true)
            }
            .loadDiskFileSynchronously()
            .resizable()
        } else {
          characterImagePlaceholder()
            .modifier(loadableContentModifier)
        }
      }
      .frame(width: 80, height: 80)
      .cornerRadius(UIConstants.cornerRadius)
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

  List {
    VStack(alignment: .leading) {
      Text("placeholder")
      CharacterDetailsFeature.FeatureView(store: placeholderStore)
    }
    VStack(alignment: .leading) {
      Text("success")
      CharacterDetailsFeature.FeatureView(store: successStore)
    }
    VStack(alignment: .leading) {
      Text("failure")
      CharacterDetailsFeature.FeatureView(store: failureStore)
    }
  }
  .listStyle(.plain)
}

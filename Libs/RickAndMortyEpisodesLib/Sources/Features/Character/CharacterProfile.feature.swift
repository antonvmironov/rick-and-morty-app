import ComposableArchitecture
import Foundation
import Kingfisher
import SharedLib
import SwiftUI

/// Namespace for the BaseCharacter feature. Serves as an anchor for project navigation.
enum CharacterProfileFeature {
  enum FeatureMode {
    case uiRendering(isPlaceholder: Bool, isShimmering: Bool)
    case snapshotRendering(imageOverride: Image)
  }

  struct FeatureView: View {
    var actualCharacter: CharacterDomainModel?
    var placeholderCharacter: CharacterDomainModel = .dummy
    private var displayCharacter: CharacterDomainModel {
      actualCharacter ?? placeholderCharacter
    }
    var mode: FeatureMode

    var body: some View {
      HStack(alignment: .top) {
        Group {
          if case .snapshotRendering(let imageOverride) = mode {
            imageOverride.resizable()
          } else if let imageURL = actualCharacter?.image {
            KFImage
              .url(imageURL)
              .cacheOriginalImage()
              .placeholder { _ in
                characterImagePlaceholder()
                  .skeletonDecoration(isEnabled: true, isShimmering: true)
              }
              .loadDiskFileSynchronously()
              .resizable()
          } else {
            characterImagePlaceholder()
          }
        }
        .frame(width: 80, height: 80)
        .cornerRadius(UIConstants.cornerRadius)
        VStack {
          info(label: "name", value: displayCharacter.name)
          info(
            label: "status",
            value: displayCharacter.status.rawValue
          )
          info(
            label: "species",
            value: displayCharacter.species.rawValue
          )
          info(label: "origin", value: displayCharacter.origin.name)
          info(
            label: "episodes",
            value: "\(displayCharacter.episode.count)"
          )
        }
      }
    }

    private func info(label: String, value: String) -> some View {
      HStack {
        Text(label).font(.caption)
        Spacer()
        Text(value)
          .font(.body)
          .foregroundStyle(.primary)
          .modifier(loadableContentModifier)
      }
    }

    private var loadableContentModifier: some ViewModifier {
      switch mode {
      case .uiRendering(let isPlaceholder, let isShimmering):
        SkeletonDecorationFeature.FeatureViewModifier(
          isEnabled: isPlaceholder,
          isShimmering: isShimmering,
        )
      case .snapshotRendering:
        SkeletonDecorationFeature.FeatureViewModifier(
          isEnabled: false,
          isShimmering: false,
        )
      }
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
  List {
    VStack(alignment: .leading) {
      Text("baseline")
      CharacterProfileFeature.FeatureView(
        actualCharacter: .dummy,
        mode: .uiRendering(isPlaceholder: false, isShimmering: false),
      )
    }
    VStack(alignment: .leading) {
      Text("placeholder")
      CharacterProfileFeature.FeatureView(
        actualCharacter: .dummy,
        mode: .uiRendering(isPlaceholder: true, isShimmering: false),
      )
    }
    VStack(alignment: .leading) {
      Text("shimmer")
      CharacterProfileFeature.FeatureView(
        actualCharacter: .dummy,
        mode: .uiRendering(isPlaceholder: false, isShimmering: true),
      )
    }
    VStack(alignment: .leading) {
      Text("placeholder & shimmer")
      CharacterProfileFeature.FeatureView(
        actualCharacter: .dummy,
        mode: .uiRendering(isPlaceholder: true, isShimmering: true),
      )
    }
    VStack(alignment: .leading) {
      Text("snapshot")
      CharacterProfileFeature.FeatureView(
        actualCharacter: .dummy,
        mode: .snapshotRendering(
          imageOverride: Image(systemName: "person.circle")
        ),
      )
    }
  }
  .listStyle(.plain)
}

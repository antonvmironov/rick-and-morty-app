import Foundation
import Kingfisher
import SharedLib
import SwiftUI

extension CharacterProfileFeature {
  enum FeatureMode {
    case uiRendering(isPlaceholder: Bool, isShimmering: Bool)
    case snapshotRendering(imageOverride: Image)
  }

  struct FeatureView: View {
    var actualCharacter: Deps.Character?
    var placeholderCharacter: Deps.Character = .dummy
    private var displayCharacter: Deps.Character {
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
          info(
            label: "origin",
            value: displayCharacter.origin.name
          )
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
        Deps.SkeletonDecoration.FeatureViewModifier(
          isEnabled: isPlaceholder,
          isShimmering: isShimmering,
        )
      case .snapshotRendering:
        Deps.SkeletonDecoration.FeatureViewModifier(
          isEnabled: false,
          isShimmering: false,
        )
      }
    }

    private func characterImagePlaceholder() -> some View {
      RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
        .fill(UIConstants.inPreview ? .gray : Color("SecondaryBackground"))
        .modifier(loadableContentModifier)
    }
  }
}

private typealias Subject = CharacterProfileFeature
#Preview {
  List {
    VStack(alignment: .leading) {
      Text("baseline")
      Subject.FeatureView(
        actualCharacter: .dummy,
        mode: .uiRendering(isPlaceholder: false, isShimmering: false),
      )
    }
    VStack(alignment: .leading) {
      Text("placeholder")
      Subject.FeatureView(
        actualCharacter: .dummy,
        mode: .uiRendering(isPlaceholder: true, isShimmering: false),
      )
    }
    VStack(alignment: .leading) {
      Text("shimmer")
      Subject.FeatureView(
        actualCharacter: .dummy,
        mode: .uiRendering(isPlaceholder: false, isShimmering: true),
      )
    }
    VStack(alignment: .leading) {
      Text("placeholder & shimmer")
      Subject.FeatureView(
        actualCharacter: .dummy,
        mode: .uiRendering(isPlaceholder: true, isShimmering: true),
      )
    }
    VStack(alignment: .leading) {
      Text("snapshot")
      Subject.FeatureView(
        actualCharacter: .dummy,
        mode: .snapshotRendering(
          imageOverride: Image(systemName: "person.circle")
        ),
      )
    }
  }
  .listStyle(.plain)
}

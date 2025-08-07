import ComposableArchitecture
import Flow
import Foundation
import Kingfisher
import SharedLib
import Shimmer
import SwiftUI

extension CharacterBriefFeature {
  @MainActor protocol FeatureViewModel: Observable, AnyObject {
    var displayCharacter: CharacterDomainModel { get }
    var isPlaceholder: Bool { get }
    var isShimmering: Bool { get }
    var characterIDString: String { get }
    var characterLoadingSuccess: CharacterDomainModel? { get }
    var characterLoadingFailureMessage: String? { get }
    func preloadIfNeeded()
    func reloadOnFailure()
  }

  struct FeatureView<ViewModel: FeatureViewModel>: View {
    @Bindable
    var viewModel: ViewModel

    init(viewModel: ViewModel) {
      self.viewModel = viewModel
    }

    var body: some View {
      characterContentView(character: viewModel.displayCharacter)
        .onAppear {
          viewModel.preloadIfNeeded()
        }
    }

    private func reloadView() -> some View {
      return Button(
        action: {
          viewModel.reloadOnFailure()
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
        isEnabled: viewModel.isPlaceholder,
        isShimmering: viewModel.isShimmering,
      )
    }

    private func characterContentView(
      character: CharacterDomainModel
    ) -> some View {
      HStack(spacing: UIConstants.space) {
        VStack(alignment: .leading) {
          HStack {
            Text(viewModel.characterIDString)
              .font(.body)
              .fontDesign(.monospaced)
              .padding(UIConstants.space / 2)
              .frame(
                minWidth: UIConstants.space * 6,
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
          if viewModel.characterLoadingFailureMessage != nil {
            VStack(alignment: .leading) {
              reloadView()
            }
          } else {
            Grid(alignment: .leadingFirstTextBaseline) {
              tagView(label: "species", content: character.species.rawValue)
              tagView(label: "origin", content: character.origin.name)
            }
          }
        }
        Spacer()
        characterImage()
      }
    }

    private func tagView(
      label: String,
      content: String,
    ) -> some View {
      GridRow {
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
        if let imageURL = viewModel.characterLoadingSuccess?.image {
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

  final class MockViewModel: FeatureViewModel {
    init(
      displayCharacter: CharacterDomainModel,
      isPlaceholder: Bool,
      isShimmering: Bool,
      characterIDString: String,
      characterLoadingSuccess: CharacterDomainModel? = nil,
      characterLoadingFailureMessage: String? = nil
    ) {
      self.displayCharacter = displayCharacter
      self.isPlaceholder = isPlaceholder
      self.isShimmering = isShimmering
      self.characterIDString = characterIDString
      self.characterLoadingSuccess = characterLoadingSuccess
      self.characterLoadingFailureMessage = characterLoadingFailureMessage
    }

    let displayCharacter: CharacterDomainModel
    let isPlaceholder: Bool
    let isShimmering: Bool
    let characterIDString: String
    let characterLoadingSuccess: CharacterDomainModel?
    let characterLoadingFailureMessage: String?
    func preloadIfNeeded() { /* no-op */  }
    func reloadOnFailure() { /* no-op */  }
  }
}

private typealias Subject = CharacterBriefFeature
#Preview {
  List {
    VStack(alignment: .leading) {
      Text("placeholder")
      Subject.FeatureView(
        viewModel: Subject.MockViewModel(
          displayCharacter: .dummy,
          isPlaceholder: true,
          isShimmering: true,
          characterIDString: "123"
        )
      )
    }
    VStack(alignment: .leading) {
      Text("success")
      Subject.FeatureView(
        viewModel: Subject.MockViewModel(
          displayCharacter: .dummy,
          isPlaceholder: false,
          isShimmering: false,
          characterIDString: "123",
          characterLoadingSuccess: .dummy,
        )
      )
    }
    VStack(alignment: .leading) {
      Text("failure")
      Subject.FeatureView(
        viewModel: Subject.MockViewModel(
          displayCharacter: .dummy,
          isPlaceholder: false,
          isShimmering: false,
          characterIDString: "123",
          characterLoadingFailureMessage: "something went wrong",
        )
      )
    }
  }
  .listStyle(.plain)
}

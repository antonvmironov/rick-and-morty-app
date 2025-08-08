import Foundation
import Kingfisher
import SharedLib
import Shimmer
import SwiftUI

extension CharacterDetailsFeature {
  @MainActor protocol FeatureViewModel: AnyObject, Observable {
    var actualCharacter: Deps.Character? { get }
    var placeholderCharacter: Deps.Character { get }
    var displayCharacter: Deps.Character { get }
    var isPlaceholder: Bool { get }
    var isShimmering: Bool { get }
    var exported: Deps.Export.TransferableCharacter? { get }
    func preloadIfNeeded()
  }

  enum A11yIDs: String, A11yIDProvider {
    case exportToPDF = "export-to-pdf"
    var a11yID: String { rawValue }
  }

  struct FeatureView<ViewModel: FeatureViewModel>: View {
    @Bindable
    var viewModel: ViewModel

    init(viewModel: ViewModel) {
      self.viewModel = viewModel
    }

    var body: some View {
      List {
        Section {
          Deps.Profile.FeatureView(
            actualCharacter: viewModel.actualCharacter,
            placeholderCharacter: viewModel.placeholderCharacter,
            mode: .uiRendering(
              isPlaceholder: viewModel.isPlaceholder,
              isShimmering: viewModel.isShimmering
            ),
          )
          if let exported = viewModel.exported {
            VStack(alignment: .center) {
              shareLink(
                exported: exported,
                character: viewModel.displayCharacter
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
      .navigationTitle(viewModel.displayCharacter.name)
      .onAppear {
        viewModel.preloadIfNeeded()
      }
    }

    private func shareLink(
      exported: Deps.Export.TransferableCharacter,
      character: CharacterDomainModel
    ) -> some View {
      ShareLink(
        item: Deps.Export.transferrable(
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

  final class MockViewModel: FeatureViewModel {
    let actualCharacter: Deps.Character?
    let placeholderCharacter: Deps.Character
    var displayCharacter: Deps.Character {
      actualCharacter ?? placeholderCharacter
    }
    var isPlaceholder: Bool
    var isShimmering: Bool
    var exported: Deps.Export.TransferableCharacter?

    init(
      actualCharacter: Deps.Character? = nil,
      placeholderCharacter: Deps.Character = .dummy,
      isPlaceholder: Bool = false,
      isShimmering: Bool = false,
      exported: Deps.Export.TransferableCharacter? = nil
    ) {
      self.actualCharacter = actualCharacter
      self.placeholderCharacter = placeholderCharacter
      self.isPlaceholder = isPlaceholder
      self.isShimmering = isShimmering
      self.exported = exported
    }
    func preloadIfNeeded() { /* no-op */  }
  }
}

private typealias Subject = CharacterDetailsFeature
#Preview {
  NavigationStack {
    VStack {
      Subject.FeatureView(
        viewModel: Subject.MockViewModel(
          isPlaceholder: true,
          isShimmering: true,
        )
      )
      Subject.FeatureView(
        viewModel: Subject.MockViewModel(
          actualCharacter: .dummy,
        )
      )
      Subject.FeatureView(
        viewModel: Subject.MockViewModel(
          isPlaceholder: true,
        )
      )
      Spacer()
    }
  }
}

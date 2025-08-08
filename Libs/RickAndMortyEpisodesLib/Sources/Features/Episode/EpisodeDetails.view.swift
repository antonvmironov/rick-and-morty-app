import Foundation
import SharedLib
import SwiftUI

extension EpisodeDetailsFeature {
  @MainActor protocol FeatureViewModel: AnyObject, Observable {
    associatedtype CharacterViewModel: Deps.CharacterBrief.FeatureViewModel
    associatedtype
      CharacterDetailsViewModel: Deps.CharacterDetails.FeatureViewModel

    var characterViewModels: [CharacterViewModel] { get }
    var selectedCharacterViewModel: CharacterDetailsViewModel? { get }
    var episode: Deps.Episode { get }
    var airedOnString: String { get }
    var isCharacterDetailsPresented: Bool { get set }
    func present(characterURL: URL)
    func preloadIfNeeded()
  }

  enum A11yIDs: A11yIDProvider {
    case characterRow(id: String)
    var a11yID: String {
      switch self {
      case .characterRow(let id): "character-row-\(id)"
      }
    }
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
          ForEach(viewModel.characterViewModels) { characterViewModel in
            row(characterViewModel: characterViewModel)
          }
        } header: {
          sectionHeader()
        }
      }
      .listStyle(.plain)
      .navigationTitle(viewModel.episode.name)
      .onAppear {
        viewModel.preloadIfNeeded()
      }
      .navigationDestination(
        isPresented: $viewModel.isCharacterDetailsPresented
      ) {
        if let nestedViewModel = viewModel.selectedCharacterViewModel {
          Deps.CharacterDetails.FeatureView(viewModel: nestedViewModel)
        } else {
          Text("Unable to load character details. Please try again later.")
        }
      }
    }

    private func row(
      characterViewModel: ViewModel.CharacterViewModel
    ) -> some View {
      Button(
        action: { [characterURL = characterViewModel.characterURL] in
          viewModel.present(characterURL: characterURL)
        },
        label: {
          HStack {
            Deps.CharacterBrief.FeatureView(viewModel: characterViewModel)
            Image(systemName: "chevron.right")
          }
        }
      )
      .listRowSeparator(.hidden)
      .tag(characterViewModel.id)
      .a11yID(A11yIDs.characterRow(id: characterViewModel.characterIDString))
      .accessibilityElement(children: .ignore)
      .accessibilityAction { [characterURL = characterViewModel.characterURL] in
        viewModel.present(characterURL: characterURL)
      }
      .accessibilityLabel(
        "Character \(characterViewModel.displayCharacter.name)"
      )
      .accessibilityAddTraits(.isButton)
    }

    private func sectionHeader() -> some View {
      VStack(alignment: .center) {
        HStack(spacing: UIConstants.space) {
          Text("Episode \(viewModel.episode.episode)")
            .font(.caption)
            .tagDecoration()
          Text(
            "Aired on \(viewModel.airedOnString))"
          )
          .font(.caption)
          .fontDesign(.monospaced)
          .tagDecoration()
        }
        Text("characters in this episode")
          .font(.title3)
      }
      .frame(maxWidth: .infinity)
    }
  }

  final class MockViewModel: FeatureViewModel {
    typealias CharacterViewModel = Deps.CharacterBrief.MockViewModel
    typealias CharacterDetailsViewModel = Deps.CharacterDetails.MockViewModel

    static func preview() -> Self {
      .init(characterViewModels: [
        CharacterViewModel.success()
      ])
    }
    init(
      episode: EpisodeDomainModel = .dummy,
      isCharacterDetailsPresented: Bool = false,
      airedOnString: String = "11/22/33",
      characterViewModels: [CharacterViewModel]
    ) {
      self.episode = episode
      self.isCharacterDetailsPresented = isCharacterDetailsPresented
      self.characterViewModels = characterViewModels
      self.airedOnString = airedOnString
    }

    let episode: EpisodeDomainModel
    var isCharacterDetailsPresented: Bool
    let airedOnString: String
    let characterViewModels: [CharacterViewModel]
    var selectedCharacterViewModel: CharacterDetailsViewModel? { nil }
    func present(characterURL: URL) { /* no-op */  }
    func preloadIfNeeded() { /* no-op */  }
  }
}

private typealias Subject = EpisodeDetailsFeature
#Preview {
  @Previewable @State var viewModel = Subject.MockViewModel.preview()
  NavigationStack {
    Subject.FeatureView(viewModel: viewModel)
  }
}

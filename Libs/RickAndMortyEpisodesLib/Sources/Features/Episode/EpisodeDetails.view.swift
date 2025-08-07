import Foundation
import SharedLib
import SwiftUI

extension EpisodeDetailsFeature {
  @MainActor protocol FeatureViewModel: AnyObject, Observable {
    associatedtype CharacterViewModel: CharacterBriefFeature.FeatureViewModel
    associatedtype
      CharacterDetailsViewModel: CharacterDetailsFeature.FeatureViewModel

    var characterViewModels: [CharacterViewModel] { get }
    var selectedCharacterViewModel: CharacterDetailsViewModel? { get }
    var episode: EpisodeDomainModel { get }
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
          CharacterDetailsFeature.FeatureView(viewModel: nestedViewModel)
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
            CharacterBriefFeature.FeatureView(viewModel: characterViewModel)
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
            "Aired on \(BaseEpisodeFeature.formatAirDate(episode: viewModel.episode))"
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
    typealias CharacterViewModel = CharacterBriefFeature.MockViewModel
    typealias CharacterDetailsViewModel = CharacterDetailsFeature.MockViewModel

    init(
      episode: EpisodeDomainModel = .dummy,
      isCharacterDetailsPresented: Bool = false,
      characterViewModels: [CharacterViewModel]
    ) {
      self.episode = episode
      self.isCharacterDetailsPresented = isCharacterDetailsPresented
      self.characterViewModels = characterViewModels
    }

    let episode: EpisodeDomainModel
    var isCharacterDetailsPresented: Bool
    let characterViewModels: [CharacterViewModel]
    var selectedCharacterViewModel: CharacterDetailsViewModel? { nil }
    func present(characterURL: URL) { /* no-op */  }
    func preloadIfNeeded() { /* no-op */  }
  }
}

private typealias Subject = EpisodeDetailsFeature
#Preview {
  NavigationStack {
    Subject.FeatureView(
      viewModel: Subject.MockViewModel(
        characterViewModels: [
          .success()
        ])
    )
  }
}

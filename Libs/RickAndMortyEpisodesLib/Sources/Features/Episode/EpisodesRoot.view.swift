import Foundation
import SharedLib
import SwiftUI

extension EpisodesRootFeature {
  @MainActor protocol FeatureViewModel: AnyObject, Observable {
    associatedtype EpisodeListViewModel: Deps.EpisodeList.FeatureViewModel
    associatedtype EpisodeDetailsViewModel: Deps.EpisodeDetails.FeatureViewModel
    var isPresentingEpisodeDetails: Bool { get set }
    var episodeList: EpisodeListViewModel { get }
    var selectedEpisodeDetails: EpisodeDetailsViewModel? { get }
  }

  struct FeatureView<ViewModel: FeatureViewModel>: View {
    @Bindable
    var viewModel: ViewModel

    init(viewModel: ViewModel) {
      self.viewModel = viewModel
    }

    var body: some View {
      Deps.EpisodeList.FeatureView(viewModel: viewModel.episodeList)
        .navigationTitle("Episode List")
        .navigationDestination(
          isPresented: $viewModel.isPresentingEpisodeDetails
        ) {
          if let nestedViewModel = viewModel.selectedEpisodeDetails {
            EpisodeDetailsFeature.FeatureView(viewModel: nestedViewModel)
          } else {
            Text("Try again later")
          }
        }
    }
  }

  final class MockViewModel: FeatureViewModel {
    typealias EpisodeListViewModel = Deps.EpisodeList.MockViewModel
    typealias EpisodeDetailsViewModel = Deps.EpisodeDetails.MockViewModel

    static func preview() -> Self {
      .init(episodeList: .preview())
    }

    init(
      episodeList: EpisodeListViewModel,
      selectedEpisodeDetails: EpisodeDetailsViewModel? = nil,
      isPresentingEpisodeDetails: Bool = false
    ) {
      self.episodeList = episodeList
      self.selectedEpisodeDetails = selectedEpisodeDetails
      self.isPresentingEpisodeDetails = isPresentingEpisodeDetails
    }

    let episodeList: EpisodeListViewModel
    var selectedEpisodeDetails: EpisodeDetailsViewModel?
    var isPresentingEpisodeDetails: Bool
  }
}

private typealias Subject = EpisodesRootFeature
#Preview {
  @Previewable @State var viewModel = Subject.MockViewModel.preview()

  VStack {
    NavigationStack {
      EpisodesRootFeature.FeatureView(viewModel: viewModel)
        .navigationTitle("Test Episode List")
    }
  }
}

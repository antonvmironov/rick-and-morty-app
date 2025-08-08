import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

extension EpisodeListFeature {
  enum A11yIDs: A11yIDProvider {
    case cachedSince
    case episodeRow(id: String)
    var a11yID: String {
      switch self {
      case .cachedSince: "cached-since"
      case .episodeRow(let id): "episode-row-\(id)"
      }
    }
  }

  @MainActor protocol FeatureViewModel: AnyObject, Observable {
    var episodes: IdentifiedArrayOf<Deps.Episode> { get }
    var failureMessage: String? { get }
    var cachedSince: Date? { get }
    var hasNextPage: Bool { get }
    var isLoadingNextPage: Bool { get }
    func preloadIfNeeded()
    func refresh() async
    func presentEpisode(_ episode: Deps.Episode)
    func loadNextPage()
  }

  struct FeatureView<ViewModel: FeatureViewModel>: View {
    @Bindable
    var viewModel: ViewModel

    init(viewModel: ViewModel) {
      self.viewModel = viewModel
    }

    var body: some View {
      List {
        Section(
          content: {
            if viewModel.episodes.isEmpty {
              skeletonListItems()
            } else {
              episodeListItems()
            }
            lastItem()
          },
          header: {
            if let failureMessage = viewModel.failureMessage {
              failureView(failureMessage: failureMessage)
            } else if let date = viewModel.cachedSince,
              let dateString = cachedSinceFormatter.string(for: date)
            {
              HStack {
                Spacer()
                Text(
                  "cached on \(dateString)"
                )
                .font(.caption2)
                .a11yID(A11yIDs.cachedSince)
                .accessibilityHidden(false)
              }
            }
          }
        )
      }
      .listStyle(.plain)
      .accessibilityElement(children: .contain)
      .accessibilityLabel("Episodes list")
      .onAppear {
        viewModel.preloadIfNeeded()
      }
      .refreshable {
        await viewModel.refresh()
      }
    }

    private func episodeRow(
      episode: EpisodeDomainModel,
      isPlaceholder: Bool
    ) -> some View {
      HStack(spacing: UIConstants.space) {
        Deps.ListItem.FeatureView(
          state: .init(episode: episode, isPlaceholder: isPlaceholder)
        )
        Image(systemName: "chevron.right")
      }
    }

    private let cachedSinceFormatter: ISO8601DateFormatter = {
      let formatter = ISO8601DateFormatter()
      return formatter
    }()

    private func episodeListItems() -> some View {
      ForEach(viewModel.episodes) { episode in
        Button(
          action: { viewModel.presentEpisode(episode) },
          label: { episodeRow(episode: episode, isPlaceholder: false) }
        )
        .listRowSeparator(.hidden)
        .tag(episode.id)
        .a11yID(A11yIDs.episodeRow(id: "\(episode.id)"))
        .accessibilityElement(children: .ignore)
        .accessibilityAction { viewModel.presentEpisode(episode) }
        .accessibilityLabel("Episode \"\(episode.name)\" \(episode.episode)")
        .accessibilityAddTraits(.isButton)
      }
    }

    private func skeletonListItems() -> some View {
      ForEach(
        Array(repeatElement(EpisodeDomainModel.dummy, count: 20).enumerated()),
        id: \.offset
      ) { element in
        episodeRow(episode: element.element, isPlaceholder: true)
          .listRowSeparator(.hidden)
          .tag(element.offset)
          .accessibilityHidden(true)
      }
    }

    private func lastItem() -> some View {
      Group {
        if viewModel.hasNextPage {
          HStack {
            if viewModel.isLoadingNextPage {
              ProgressView()
              Text("Loading the next page...")
            } else {
              Text("Next page placeholder")
            }
          }
          .onAppear {
            viewModel.loadNextPage()
          }
          .frame(maxWidth: .infinity, alignment: .center)
          .listRowSeparator(.hidden)
          .tag("last-item")
        } else {
          HStack {
            Text("No new episodes")
          }
          .frame(maxWidth: .infinity, alignment: .center)
          .listRowSeparator(.hidden)
          .tag("last-item")
        }
      }
    }

    private func failureView(failureMessage: String) -> some View {
      Text("⚠️ \(failureMessage)")
        #if DEBUG
          .lineLimit(10)
        #else
          .lineLimit(2)
        #endif
        .truncationMode(.middle)
        .font(.caption)
    }
  }

  final class MockViewModel: FeatureViewModel {
    init(
      episodes: [Deps.Episode] = [],
      failureMessage: String? = nil,
      cachedSince: Date? = nil,
      hasNextPage: Bool,
      isLoadingNextPage: Bool
    ) {
      self.episodes = IdentifiedArray(uniqueElements: episodes)
      self.failureMessage = failureMessage
      self.cachedSince = cachedSince
      self.hasNextPage = hasNextPage
      self.isLoadingNextPage = isLoadingNextPage
    }

    var episodes: IdentifiedArrayOf<Deps.Episode>
    var failureMessage: String?
    var cachedSince: Date?
    var hasNextPage: Bool
    var isLoadingNextPage: Bool
    func preloadIfNeeded() { /* no-op */  }
    func refresh() { /* no-op */  }
    func presentEpisode(_ episode: EpisodeDomainModel) { /* no-op */  }
    func loadNextPage() { /* no-op */  }

    static func preview() -> Self {
      .init(
        episodes: [.dummy],
        hasNextPage: false,
        isLoadingNextPage: false
      )
    }
  }
}

private typealias Subject = EpisodeListFeature
#Preview {
  @Previewable @State var viewModel = Subject.MockViewModel.preview()
  Subject.FeatureView(viewModel: viewModel)
}

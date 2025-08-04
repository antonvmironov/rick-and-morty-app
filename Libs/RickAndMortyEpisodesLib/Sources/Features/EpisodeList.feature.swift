import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
enum EpisodeListFeature {
  typealias PaginationFeature = ContinuousPaginationFeature<
    URL, EpisodeDomainModel
  >
  typealias ListItemFeature = EpisodeBriefFeature
  typealias FeatureStore = EpisodesRootFeature.FeatureStore
  typealias Item = EpisodesRootFeature.Item

  struct FeatureView: View {
    @Bindable
    var store: FeatureStore

    init(store: FeatureStore) {
      self.store = store
    }

    var body: some View {
      List {
        Section(
          content: {
            if store.pagination.items.isEmpty {
              skeletonListItems()
            } else {
              episodeListItems()
            }
            lastItem()
          },
          header: {
            if let failureMessage = store.failureMessage {
              failureView(failureMessage: failureMessage)
            } else if let date = store.cachedSince,
              let dateString = Self.cachedSinceFormatter.string(for: date)
            {
              HStack {
                Spacer()
                Text(
                  "cached on \(dateString)"
                )
                .font(.caption2)
              }
            }
          }
        )
      }
      .listStyle(.plain)
      .onAppear {
        store.send(.preloadIfNeeded)
      }
      .refreshable {
        do {
          _ = try await withCheckedThrowingContinuation { continuation in
            store.send(.reload(continuation: continuation))
          }
        } catch {
          // TODO: handle this error
          print(error)
        }
      }
    }

    private func episodeRow(
      episode: EpisodeDomainModel,
      isPlaceholder: Bool
    ) -> some View {
      HStack(spacing: UIConstants.space) {
        ListItemFeature.FeatureView(
          state: .init(episode: episode, isPlaceholder: isPlaceholder)
        )
        Image(systemName: "chevron.right")
      }
    }

    private static let cachedSinceFormatter: ISO8601DateFormatter = {
      let formatter = ISO8601DateFormatter()
      return formatter
    }()

    private func episodeListItems() -> some View {
      ForEach(store.pagination.items) { episode in
        Button(
          action: {
            store.send(.presetEpisode(episode))
          },
          label: {
            episodeRow(episode: episode, isPlaceholder: false)
          }
        )
        .listRowSeparator(.hidden)
        .tag(episode.id)
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
      }
    }

    private func lastItem() -> some View {
      Group {
        if store.pagination.nextInput != nil {
          HStack {
            if store.pagination.pageLoading.status.isProcessing {
              ProgressView()
              Text("Loading the next page...")
            } else {
              Text("Next page placeholder")
            }
          }
          .onAppear {
            store.send(.loadNextPage)
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
        .font(.caption)
    }
  }
}

#Preview {
  @Previewable @State var isPlaceholder = false
  @Previewable @State var store = EpisodesRootFeature.previewStore(
    dependencies: Dependencies.preview()
  )

  EpisodeListFeature.FeatureView(store: store)
}

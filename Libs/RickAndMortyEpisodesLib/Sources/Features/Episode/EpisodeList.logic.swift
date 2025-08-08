import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

extension EpisodeListFeature {
  typealias FeatureStore = Deps.Base.FeatureStore
  final class ProdViewModel: FeatureViewModel {
    private let store: FeatureStore
    init(store: FeatureStore) {
      self.store = store
    }

    var episodes: IdentifiedArrayOf<Deps.Episode> { store.pagination.items }
    var failureMessage: String? {
      store.pagination.pageLoading.status.failureMessage
    }
    var cachedSince: Date? {
      store.pagination.cachedSince
    }
    var hasNextPage: Bool {
      store.pagination.nextInput != nil
    }
    var isLoadingNextPage: Bool {
      store.pagination.pageLoading.status.isProcessing
    }
    func preloadIfNeeded() {
      store.send(.preloadIfNeeded)
    }
    func refresh() async {
      do {
        _ = try await withCheckedThrowingContinuation { continuation in
          store.send(
            .reload(
              invalidateCache: true,
              continuation: continuation
            )
          )
        }
      } catch {
        // TODO: handle this error
        print(error)
      }
    }
    func presentEpisode(_ episode: EpisodeDomainModel) {
      store.send(.presetEpisode(episode))
    }
    func loadNextPage() {
      store.send(.loadNextPage)
    }
  }
}

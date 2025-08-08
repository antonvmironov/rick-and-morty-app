import ComposableArchitecture
import Foundation
import SharedLib

extension SettingsFeature {
  typealias FeatureStore = StoreOf<FeatureReducer>
  @Observable final class ProdViewModel: FeatureViewModel {
    private let store: FeatureStore

    init(store: FeatureStore) {
      self.store = store
    }

    var version: String {
      (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)
        ?? "unknown"
    }
    var cacheReports: [URLCacheReport] { store.cacheReports }
    func simulateBackgroundRefresh() {
      store.send(.simulateBackgroundRefresh)
    }
    func updateCacheReports() {
      store.send(.updateCacheReports)
    }
    func clearCache(category: URLCacheCategory) {
      store.send(.clearCache(category))
    }
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    @Dependency(\.urlCacheFactory)
    var urlCacheFactory: URLCacheFactory

    @Dependency(\.backgroundRefresher)
    var backgroundRefresher: BackgroundRefresher

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .updateCacheReports:
          state.cacheReports = urlCacheFactory.allReports()
          return .none
        case .simulateBackgroundRefresh:
          return .run { _ in
            await backgroundRefresher.simulateSending()
          }
        case .clearCache(let category):
          urlCacheFactory.clearCache(category: category)
          return .none
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var cacheReports = [URLCacheReport]()
  }

  @CasePathable
  enum FeatureAction: Equatable {
    case updateCacheReports
    case simulateBackgroundRefresh
    case clearCache(URLCacheCategory)
  }
}

import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the RootFeature feature. Serves as an anchor for project navigation.
public enum RootFeature {
  typealias FeatureStore = StoreOf<FeatureReducer>
  typealias EndpointsLoadingFeature = ProcessHostFeature<
    URL, EndpointsDomainModel
  >
  //typealias EpisodesRootFeature = EpisodesRootFeature

  @MainActor
  public static func rootView(
    apiURL: URL,
    dependencies: Dependencies
  ) -> some View {
    let store = initialStore(apiURL: apiURL, dependencies: dependencies)
    return FeatureView(store: store, apiURL: apiURL)
  }

  @MainActor
  static func initialStore(
    apiURL: URL,
    dependencies: Dependencies
  ) -> FeatureStore {
    let cachedEndpoints = try? dependencies.networkGateway
      .getCachedEndpoints(apiURL: apiURL)?.output
    let endpointsLoading = EndpointsLoadingFeature.FeatureState
      .initial(cachedSuccess: cachedEndpoints)
    let episodeList: EpisodesRootFeature.FeatureState = {
      guard let firstPageURL = cachedEndpoints?.episodes else {
        return EpisodesRootFeature.FeatureState
          .initial(firstPageURL: cachedEndpoints?.episodes)
      }
      let cachedFirstPage = try? dependencies.networkGateway
        .getPageOfCachedEpisodes(pageURL: firstPageURL)
      guard let cachedFirstPage else {
        return EpisodesRootFeature.FeatureState
          .initial(firstPageURL: cachedEndpoints?.episodes)
      }

      return EpisodesRootFeature.FeatureState
        .initialFromCache(firstPageURL: firstPageURL, pages: [cachedFirstPage])
    }()

    let initialState = FeatureState(
      endpointsLoading: endpointsLoading,
      episodeList: episodeList,
    )
    return FeatureStore(
      initialState: initialState,
      reducer: {
        FeatureReducer(apiURL: apiURL)
      },
      withDependencies: dependencies.updateDeps
    )
  }

  public struct FeatureView: View {
    @Bindable
    var store: FeatureStore

    let apiURL: URL

    init(store: FeatureStore, apiURL: URL) {
      self.store = store
      self.apiURL = apiURL
    }

    public var body: some View {
      EpisodesRootFeature.FeatureView(
        store: store.scope(state: \.episodeList, action: \.episodeList)
      )
      .onAppear {
        store.send(.preloadIfNeeded)
      }
    }
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    let apiURL: URL

    @Dependency(\.networkGateway)
    var networkGateway: NetworkGateway

    var body: some ReducerOf<Self> {
      coordinatingReducer
      Scope(state: \.endpointsLoading, action: \.endpointsLoading) {
        [networkGateway] in
        EndpointsLoadingFeature.FeatureReducer { apiURL in
          let response = try await networkGateway.getEndpoints(
            apiURL: apiURL
          )
          return response.output
        }
      }
      Scope(state: \.episodeList, action: \.episodeList) {
        EpisodesRootFeature.FeatureReducer()
      }
    }

    var coordinatingReducer: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .preloadIfNeeded:
          if let endpoints = state.endpointsLoading.status.success {
            let action: Action = .episodeList(
              .pagination(.setFirstInput(input: endpoints.episodes))
            )
            return .send(action)
          } else {
            return .send(.endpointsLoading(.process(apiURL)))
          }
        case .endpointsLoading(.finishProcessing(let endpoints)):
          let action: Action = .episodeList(
            .pagination(.setFirstInput(input: endpoints.episodes))
          )
          return .send(action)
        default:
          return .none
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var endpointsLoading: EndpointsLoadingFeature.FeatureState
    var episodeList: EpisodesRootFeature.FeatureState
  }

  @CasePathable
  enum FeatureAction {
    case preloadIfNeeded
    case endpointsLoading(EndpointsLoadingFeature.FeatureAction)
    case episodeList(EpisodesRootFeature.FeatureAction)
  }
}

#Preview {
  @Previewable let dependencies = Dependencies.preview()
  NavigationStack {
    RootFeature
      .rootView(
        apiURL: MockNetworkGateway.exampleAPIURL,
        dependencies: dependencies
      )
      .navigationTitle("Test Episode List")
  }
}

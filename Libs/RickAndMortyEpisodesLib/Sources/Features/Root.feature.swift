import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
public enum RootFeature {
  // constants and shared functions go here

  @MainActor
  public static func rootView(apiURL: URL, dependencies: Dependencies) -> some View {
    let store = RootStore.initial(apiURL: apiURL) { deps in
      dependencies.updateDeps(&deps)
    }
    return RootView(store: store)
  }
}

public struct RootView: View {
  var store: RootStore

  init(store: RootStore) {
    self.store = store
  }

  public var body: some View {
    EpisodeListView(
      store: store.scope(state: \.episodeList, action: \.episodeList)
    )
    .onAppear {
      store.send(.endpointsLoading(.preloadIfNeeded))
    }
  }
}

#Preview {
  @Previewable let dependencies = Dependencies.preview()
  NavigationStack {
    RootFeature
      .rootView(apiURL: MockNetworkGateway.exampleAPIURL, dependencies: dependencies)
      .navigationTitle("Test Episode List")
  }
}

typealias RootStore = StoreOf<RootReducer>
extension RootStore {
  static func initial(
    apiURL: URL,
    withDependencies: @escaping (inout DependencyValues) -> Void
  ) -> RootStore {
    let initialState = RootState(
      endpointsLoading: ProcessHostState<EndpointsDomainModel>.initial(),
      episodeList: EpisodeListState.initial()
    )
    return RootStore(
      initialState: initialState,
      reducer: {
        RootReducer(apiURL: apiURL)
      },
      withDependencies: withDependencies
    )
  }
}

@Reducer
struct RootReducer {
  let apiURL: URL

  typealias State = RootState
  typealias Action = RootAction

  @Dependency(\.networkGateway)
  var networkGateway: NetworkGateway

  var body: some ReducerOf<Self> {
    coordinatingReducer
    Scope(state: \.endpointsLoading, action: \.endpointsLoading) { [networkGateway, apiURL] in
      ProcessHostReducer {
        let response = try await networkGateway.getEndpoints(
          apiURL: apiURL
        )
        return response.output
      }
    }
    Scope(state: \.episodeList, action: \.episodeList) {
      EpisodeListReducer()
    }
  }

  var coordinatingReducer: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .endpointsLoading(.finishProcessing(let endpoint)):
        let action: Action = .episodeList(
          .setFirstPageLoadingURL(pageURL: endpoint.episodes)
        )
        return .send(action)
      default:
        return .none
      }
    }
  }
}

@ObservableState
struct RootState: Equatable {
  var endpointsLoading: ProcessHostState<EndpointsDomainModel>
  var episodeList: EpisodeListState
}

@CasePathable
enum RootAction {
  case endpointsLoading(ProcessHostAction<EndpointsDomainModel>)
  case episodeList(EpisodeListAction)
}

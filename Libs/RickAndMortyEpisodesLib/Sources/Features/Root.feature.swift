import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
public enum RootFeature {
  // constants and shared functions go here

  @MainActor
  public static func rootView(
    apiURL: URL,
    dependencies: Dependencies
  ) -> some View {
    let store = RootStore.initial { deps in
      dependencies.updateDeps(&deps)
    }
    return RootView(store: store, apiURL: apiURL)
  }
}

public struct RootView: View {
  @State
  var store: RootStore

  let apiURL: URL

  init(store: RootStore, apiURL: URL) {
    self.store = store
    self.apiURL = apiURL
  }

  public var body: some View {
    EpisodeListView(
      store: store.scope(state: \.episodeList, action: \.episodeList)
    )
    .onAppear {
      store.send(.endpointsLoading(.process(apiURL)))
    }
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

typealias RootStore = StoreOf<RootReducer>
extension RootStore {
  static func initial(
    withDependencies: @escaping (inout DependencyValues) -> Void
  ) -> RootStore {
    let initialState = RootState(
      endpointsLoading: ProcessHostState<URL, EndpointsDomainModel>.initial(),
      episodeList: EpisodeListState.initial()
    )
    return RootStore(
      initialState: initialState,
      reducer: {
        RootReducer()
      },
      withDependencies: withDependencies
    )
  }
}

@Reducer
struct RootReducer {
  typealias State = RootState
  typealias Action = RootAction

  @Dependency(\.networkGateway)
  var networkGateway: NetworkGateway

  var body: some ReducerOf<Self> {
    coordinatingReducer
    Scope(state: \.endpointsLoading, action: \.endpointsLoading) {
      [networkGateway] in
      ProcessHostReducer { apiURL in
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
          .setFirstPageURL(pageURL: endpoint.episodes)
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
  var endpointsLoading: ProcessHostState<URL, EndpointsDomainModel>
  var episodeList: EpisodeListState
}

@CasePathable
enum RootAction {
  case endpointsLoading(ProcessHostAction<URL, EndpointsDomainModel>)
  case episodeList(EpisodeListAction)
}

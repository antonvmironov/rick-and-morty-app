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
    let store = initialStore { deps in
      dependencies.updateDeps(&deps)
    }
    return FeatureView(store: store, apiURL: apiURL)
  }

  @MainActor
  static func initialStore(
    withDependencies: @escaping (inout DependencyValues) -> Void
  ) -> FeatureStore {
    let initialState = FeatureState(
      endpointsLoading: EndpointsLoadingFeature.FeatureState.initial(),
      episodeList: EpisodesRootFeature.FeatureState.initial(firstPageURL: nil)
    )
    return FeatureStore(
      initialState: initialState,
      reducer: {
        FeatureReducer()
      },
      withDependencies: withDependencies
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
        store.send(.endpointsLoading(.process(apiURL)))
      }
    }
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

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
        case .endpointsLoading(.finishProcessing(let endpoint)):
          let action: Action = .episodeList(
            .pagination(.setFirstInput(input: endpoint.episodes))
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

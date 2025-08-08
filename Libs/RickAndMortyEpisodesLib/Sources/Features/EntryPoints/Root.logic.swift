import ComposableArchitecture
import Foundation
import SharedLib

extension RootFeature {
  @MainActor
  static func initialProdViewModel(
    apiURL: URL,
    dependencies: Dependencies
  ) -> ProdViewModel {
    let cachedEndpoints = try? dependencies.networkGateway
      .getCached(operation: NetworkOperation.endpoints(apiURL: apiURL))?
      .decodedResponse
    let endpointsLoading = Deps.EndpointsLoading.FeatureState
      .initial(cachedSuccess: cachedEndpoints)

    let episodeList: Deps.EpisodesRoot.FeatureState = {
      guard let firstPageURL = cachedEndpoints?.episodes else {
        return Deps.EpisodesRoot.FeatureState
          .initial(firstPageURL: cachedEndpoints?.episodes)
      }
      let cachedFirstPage = try? dependencies.networkGateway
        .getCached(
          operation: NetworkOperation.pageOfEpisodes(pageURL: firstPageURL)
        )?
        .decodedResponse
      guard let cachedFirstPage else {
        return Deps.EpisodesRoot.FeatureState
          .initial(firstPageURL: cachedEndpoints?.episodes)
      }

      return Deps.EpisodesRoot.FeatureState
        .initialFromCache(firstPageURL: firstPageURL, pages: [cachedFirstPage])
    }()

    let initialState = FeatureState(
      endpointsLoading: endpointsLoading,
      episodeList: episodeList,
      settings: .init()
    )
    let store = FeatureStore(
      initialState: initialState,
      reducer: {
        FeatureReducer(apiURL: apiURL)
      },
      withDependencies: dependencies.updateDeps
    )
    return ProdViewModel(store: store)
  }

  typealias FeatureStore = StoreOf<FeatureReducer>
  final class ProdViewModel: FeatureViewModel {
    typealias EpisodesRootViewModel = Deps.EpisodesRoot.ProdViewModel
    typealias SettingsViewModel = Deps.Settings.ProdViewModel
    private let store: FeatureStore

    init(store: FeatureStore) {
      self.store = store
    }

    var episodesRoot: Deps.EpisodesRoot.ProdViewModel {
      .init(store: store.scope(state: \.episodeList, action: \.episodeList))
    }
    var settingsViewModel: Deps.Settings.ProdViewModel {
      .init(store: store.scope(state: \.settings, action: \.settings))
    }
    var isSettingsPresented: Bool {
      get { store.isSettingsPresented }
      set { store.isSettingsPresented = newValue }
    }
    func preloadIfNeeded(onRefresh: @escaping @MainActor @Sendable () -> Void) {
      store.send(.preloadIfNeeded(didRefresh: didRefresh))
    }
    func didRefresh() {
      store.send(.didRefreshOnBackground)
    }
    func toggleSettingsPresentation() {
      store.send(.toggleSettingsPresentation)
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var endpointsLoading: Deps.EndpointsLoading.FeatureState
    var episodeList: Deps.EpisodesRoot.FeatureState
    var settings: Deps.Settings.FeatureState
    var isSettingsPresented = false
  }

  @CasePathable
  enum FeatureAction: BindableAction {
    case preloadIfNeeded(didRefresh: @MainActor @Sendable () -> Void)
    case toggleSettingsPresentation
    case didRefreshOnBackground
    case endpointsLoading(Deps.EndpointsLoading.FeatureAction)
    case episodeList(Deps.EpisodesRoot.FeatureAction)
    case settings(Deps.Settings.FeatureAction)
    case binding(BindingAction<FeatureState>)
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    let apiURL: URL

    @Dependency(\.networkGateway)
    var networkGateway: NetworkGateway

    @Dependency(\.backgroundRefresher)
    var backgroundRefresher: BackgroundRefresher

    var body: some ReducerOf<Self> {
      coordinatingReducer
      Scope(
        state: \.endpointsLoading,
        action: \.endpointsLoading
      ) { [networkGateway] in
        Deps.EndpointsLoading.FeatureReducer { apiURL in
          let response =
            try await networkGateway
            .get(operation: NetworkOperation.endpoints(apiURL: apiURL))
          return response.decodedResponse
        }
      }
      Scope(state: \.episodeList, action: \.episodeList) {
        Deps.EpisodesRoot.FeatureReducer()
      }
      Scope(state: \.settings, action: \.settings) {
        Deps.Settings.FeatureReducer()
      }
      BindingReducer()
    }

    var coordinatingReducer: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .preloadIfNeeded(let didRefresh):
          if let endpoints = state.endpointsLoading.status.success {
            let episodesPageURL = endpoints.episodes
            let action: Action = .episodeList(
              .pagination(.setFirstInput(input: episodesPageURL))
            )
            let operation = NetworkOperation.pageOfEpisodes(
              pageURL: episodesPageURL
            )
            return .merge(
              .send(action),
              .run { [backgroundRefresher] send in
                await backgroundRefresher.scheduleRefreshing(
                  operation: operation,
                  id: "episodes-page"
                ) {
                  await didRefresh()
                }
              }
            )
          } else {
            return .send(.endpointsLoading(.process(apiURL)))
          }
        case .toggleSettingsPresentation:
          state.isSettingsPresented.toggle()
          return .none
        case .didRefreshOnBackground:
          return .send(
            .episodeList(
              .reload(
                invalidateCache: false,
                continuation: nil
              )
            )
          )
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
}

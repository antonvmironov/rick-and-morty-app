import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodesRoot feature. Serves as an anchor for project navigation.
enum EpisodesRootFeature: Feature {
  typealias Item = EpisodeDomainModel
  typealias PaginationFeature = ContinuousPaginationFeature<URL, Item>
  typealias ListItemFeature = EpisodeBriefFeature

  enum AX {

  }

  @MainActor
  static func previewStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    let initialState = FeatureState(
      pagination: .initial(
        firstInput: MockNetworkGateway.episodeFirstPageAPIURL
      )
    )
    return FeatureStore(
      initialState: initialState,
      reducer: { FeatureReducer() },
      withDependencies: dependencies.updateDeps
    )
  }

  struct FeatureView: View {
    @Bindable
    var store: FeatureStore

    init(store: FeatureStore) {
      self.store = store
    }

    var body: some View {
      EpisodeListFeature.FeatureView(store: store)
        .navigationTitle("Episode List")
        .navigationDestination(
          item: $store.scope(
            state: \.selectedEpisodeDetails?.value,
            action: \.selectedEpisodeDetails
          )
        ) { nestedStore in
          EpisodeDetailsFeature.FeatureView(store: nestedStore)
            .storeActions(isEnabled: store.selectedEpisodeDetails != nil)
        }
    }
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    @Dependency(\.networkGateway)
    var networkGateway

    @Dependency(\.urlCacheFactory)
    var urlCacheFactory

    var body: some ReducerOf<Self> {
      episodeDetailsReducer
      userInputReducer
      reloadReducer
      paginationReducer
      BindingReducer()
    }

    private var reloadReducer: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .reload(let continuation):
          return .run { [urlCacheFactory] send in
            urlCacheFactory.clearCache(category: .episodes)
            await send(.pagination(.reload(continuation: continuation)))
          }
        default:
          return .none
        }
      }
    }

    private var episodeDetailsReducer: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .selectedEpisodeDetails(.dismiss):
          print("hi")
          return .none
        default:
          return .none
        }
      }
      .ifLet(\.$selectedEpisodeDetails, action: \.selectedEpisodeDetails) {
        Scope(state: \.value, action: \.self) {
          EpisodeDetailsFeature.FeatureReducer()
        }
      }
    }

    private var userInputReducer: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .preloadIfNeeded:
          return .send(.pagination(.loadFirstPageIfNeeded))
        case .loadNextPage:
          return .send(.pagination(.loadNextPage()))
        case .presetEpisode(let episode):
          return .run { send in
            await presentEpisode(episode: episode, send: send)
          }
        case .didLoadEpisodeState(let selectedEpisodeDetails):
          state.selectedEpisodeDetails = selectedEpisodeDetails
          return .send(.selectedEpisodeDetails(.presented(.preloadIfNeeded)))
        default:
          return .none
        }
      }
    }

    private func presentEpisode(
      episode: EpisodeDomainModel,
      send: Send<Action>
    ) async {
      let state = EpisodeDetailsFeature.FeatureState.initial(
        episode: episode,
        getCachedCharacter: {
          try? networkGateway.getCachedCharacter(url: $0)?.output
        }
      )
      let selectedEpisodeDetails = Identified(state, id: \.episode.id)
      await UISelectionFeedbackGenerator().selectionChanged()
      await send(.didLoadEpisodeState(selectedEpisodeDetails))
    }

    private var paginationReducer: some ReducerOf<Self> {
      Scope(state: \.pagination, action: \.pagination) {
        PaginationFeature.FeatureReducer(
          getPage: { pageURL in
            try await networkGateway
              .getPageOfEpisodes(
                pageURL: pageURL,
                cachePolicy: .returnCacheDataElseLoad
              )
          },
          getNextInput: \.payload.info.next,
          isPageFirst: { $0.payload.info.prev == nil },
        )
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var pagination: PaginationFeature.FeatureState
    @Presents
    var selectedEpisodeDetails:
      Identified<EpisodeID, EpisodeDetailsFeature.FeatureState>?

    var cachedSince: Date? { pagination.cachedSince }
    var failureMessage: String? { pagination.pageLoading.status.failureMessage }

    static func initial(firstPageURL: URL?) -> Self {
      FeatureState(pagination: .initial(firstInput: firstPageURL))
    }

    static func initialFromCache(
      firstPageURL: URL,
      pages: [PaginationFeature.Page],
    ) -> Self {
      FeatureState(
        pagination: .initialFromCache(
          firstInput: firstPageURL,
          pages: pages,
          nextInput: pages.last?.payload.info.next,
        )
      )
    }
  }

  @CasePathable
  enum FeatureAction: BindableAction {
    case presetEpisode(EpisodeDomainModel)
    case didLoadEpisodeState(
      Identified<EpisodeID, EpisodeDetailsFeature.FeatureState>
    )
    case loadNextPage
    case preloadIfNeeded
    case reload(continuation: PaginationFeature.PageLoadingContinuation?)

    case pagination(PaginationFeature.FeatureAction)
    case selectedEpisodeDetails(
      PresentationAction<EpisodeDetailsFeature.FeatureAction>
    )
    case binding(BindingAction<FeatureState>)
  }
}

#Preview {
  @Previewable @State var isPlaceholder = false
  @Previewable @State var store = EpisodesRootFeature.previewStore(
    dependencies: Dependencies.preview()
  )

  VStack {
    NavigationStack {
      EpisodesRootFeature.FeatureView(store: store)
        .navigationTitle("Test Episode List")
    }
  }
}

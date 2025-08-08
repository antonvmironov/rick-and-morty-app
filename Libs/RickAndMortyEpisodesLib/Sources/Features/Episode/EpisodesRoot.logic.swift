import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

extension EpisodesRootFeature {
  typealias FeatureStore = StoreOf<FeatureReducer>
  final class ProdViewModel: FeatureViewModel {
    typealias EpisodeListViewModel = Deps.EpisodeList.ProdViewModel
    typealias EpisodeDetailsViewModel = Deps.EpisodeDetails.ProdViewModel

    private let store: FeatureStore

    init(store: FeatureStore) {
      self.store = store
    }

    var episodeList: Deps.EpisodeList.ProdViewModel {
      .init(store: store)
    }

    var selectedEpisodeDetails: Deps.EpisodeDetails.ProdViewModel? {
      guard
        let nestedStore = store.scope(
          state: \.selectedEpisodeDetails,
          action: \.selectedEpisodeDetails
        )
      else { return nil }
      return .init(store: nestedStore)
    }
    var isPresentingEpisodeDetails: Bool {
      get { store.isPresentingEpisodeDetails }
      set { store.isPresentingEpisodeDetails = newValue }
    }
  }

  @CasePathable
  enum FeatureRoute: Sendable, Hashable {
    case root
    case episodeDetails
  }

  @CasePathable
  enum FeatureAction: BindableAction {
    case presetEpisode(Deps.Episode)
    case didPrepareEpisodeForPresentation(Deps.EpisodeDetails.FeatureState)
    case loadNextPage
    case preloadIfNeeded
    case reload(
      invalidateCache: Bool,
      continuation: Deps.Pagination.Deps.PageLoadingContinuation?
    )

    case pagination(Deps.Pagination.FeatureAction)
    case selectedEpisodeDetails(Deps.EpisodeDetails.FeatureAction)
    case binding(BindingAction<FeatureState>)
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
        case .reload(let invalidateCache, let continuation):
          return .run { [urlCacheFactory] send in
            if invalidateCache {
              urlCacheFactory.clearCache(category: .episodes)
            }
            await send(.pagination(.reload(continuation: continuation)))
          }
        default:
          return .none
        }
      }
    }

    private var episodeDetailsReducer: some ReducerOf<Self> {
      EmptyReducer()
        .ifLet(\.selectedEpisodeDetails, action: \.selectedEpisodeDetails) {
          Deps.EpisodeDetails.FeatureReducer()
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
        case .didPrepareEpisodeForPresentation(let selectedEpisodeDetails):
          state.selectedEpisodeDetails = selectedEpisodeDetails
          state.route = .episodeDetails
          return .send(.selectedEpisodeDetails(.preloadIfNeeded))
        default:
          return .none
        }
      }
    }

    private func presentEpisode(
      episode: EpisodeDomainModel,
      send: Send<Action>
    ) async {
      let state = Deps.EpisodeDetails.FeatureState.initial(
        episode: episode,
        getCachedCharacter: {
          try? networkGateway
            .getCached(operation: NetworkOperation.character(url: $0))?
            .decodedResponse
        }
      )
      async let _ = UISelectionFeedbackGenerator().selectionChanged()
      await send(.didPrepareEpisodeForPresentation(state))
    }

    private var paginationReducer: some ReducerOf<Self> {
      Scope(state: \.pagination, action: \.pagination) {
        Deps.Pagination.FeatureReducer(
          getPage: { pageURL in
            try await networkGateway
              .get(operation: NetworkOperation.pageOfEpisodes(pageURL: pageURL))
              .decodedResponse
          },
          getNextInput: \.payload.info.next,
          isPageFirst: { $0.payload.info.prev == nil },
        )
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var pagination: Deps.Pagination.FeatureState
    var selectedEpisodeDetails: Deps.EpisodeDetails.FeatureState?
    var route: FeatureRoute = .root
    var isPresentingEpisodeDetails: Bool {
      get {
        if case .episodeDetails = route, selectedEpisodeDetails != nil {
          true
        } else {
          false
        }
      }
      set {
        route = newValue ? .episodeDetails : .root
      }
    }

    var cachedSince: Date? { pagination.cachedSince }
    var failureMessage: String? { pagination.pageLoading.status.failureMessage }

    static func initial(firstPageURL: URL?) -> Self {
      FeatureState(
        pagination: .initial(firstInput: firstPageURL),
      )
    }

    static func initialFromCache(
      firstPageURL: URL,
      pages: [Deps.Pagination.Deps.Page],
    ) -> Self {
      FeatureState(
        pagination: .initialFromCache(
          firstInput: firstPageURL,
          pages: pages,
          nextInput: pages.last?.payload.info.next,
        ),
      )
    }
  }
}

import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the EpisodesRoot feature. Serves as an anchor for project navigation.
enum EpisodesRootFeature {
  typealias Item = EpisodeDomainModel
  typealias PaginationFeature = ContinuousPaginationFeature<URL, Item>
  typealias ListItemFeature = EpisodeBriefFeature
  typealias FeatureStore = StoreOf<FeatureReducer>

  @MainActor
  static func previewStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    let initialState = FeatureState(
      pagination: .initial(
        firstInput: MockNetworkGateway.exampleAPIURL.appendingPathComponent(
          "episode"
        )
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
      BindingReducer()
      episodeDetailsReducer
      userInputReducer
      reloadReducer
      paginationReducer
    }

    var reloadReducer: some ReducerOf<Self> {
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

    var episodeDetailsReducer: some ReducerOf<Self> {
      EmptyReducer()
        .ifLet(\.$selectedEpisodeDetails, action: \.selectedEpisodeDetails) {
          Scope(state: \.value, action: \.self) {
            EpisodeDetailsFeature.FeatureReducer()
          }
        }
    }

    var userInputReducer: some ReducerOf<Self> {
      Reduce { (state: inout State, action: Action) in
        switch action {
        case .preload:
          return .send(.pagination(.loadFirstPageIfNeeded))
        case .loadNextPage:
          return .send(.pagination(.loadNextPage()))
        case .presetEpisode(let episode):
          state.selectedEpisodeDetails = Identified(
            .initial(episode: episode),
            id: \.episode.id
          )
          return .send(.selectedEpisodeDetails(.presented(.preload)))
        default:
          return .none
        }
      }
    }

    var paginationReducer: some ReducerOf<Self> {
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
  }

  @CasePathable
  enum FeatureAction: BindableAction {
    case presetEpisode(EpisodeDomainModel)
    case loadNextPage
    case preload
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

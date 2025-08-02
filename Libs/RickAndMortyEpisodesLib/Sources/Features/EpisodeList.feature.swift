import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
enum EpisodeListFeature {
  typealias PaginationFeature = ContinuousPaginationFeature<
    URL, EpisodeDomainModel
  >
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
    @State
    var store: FeatureStore

    init(store: FeatureStore) {
      self.store = store
    }

    var body: some View {
      episodeList()
        .navigationTitle("Episode List")
    }

    func episodeList() -> some View {
      List {
        if let previousFailure = store.pagination.pageLoading.status
          .failureMessage
        {
          Text("Failure \(previousFailure)")
        }

        ForEach(store.pagination.items) { episode in
          Button(
            action: {
              store.send(.presetEpisode(episode))
            },
            label: {
              HStack {
                ListItemFeature.FeatureView(episode: episode)
                Spacer()
                Image(systemName: "chevron.right")
              }
            }
          )
          .listRowSeparator(.hidden)
          .tag(episode.id)
        }
        if store.pagination.nextInput != nil {
          HStack {
            if store.pagination.pageLoading.status.isProcessing {
              ProgressView()
              Text("Loading the next page...")
            } else {
              Text("Next page placeholder")
            }
          }
          .frame(maxWidth: .infinity, alignment: .center)
          .listRowSeparator(.hidden)
          .tag("next-page")
          .onAppear {
            store.send(.pagination(.loadNextPage))
          }
        } else {
          HStack {
            Text("No new episodes")
          }
          .frame(maxWidth: .infinity, alignment: .center)
          .listRowSeparator(.hidden)
          .tag("next-page")
        }
      }
      .listStyle(.plain)
      .onAppear {
        store.send(.pagination(.loadFirstPageIfNeeded))
      }
      .navigationDestination(
        item: $store.scope(state: \.episodeDetails, action: \.episodeDetails)
      ) { store in
        EpisodeDetailsFeature.FeatureView(store: store)
      }
    }

    func presentEpisode(_ episode: EpisodeDomainModel) {
      store.send(.presetEpisode(episode))
    }
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    @Dependency(\.networkGateway)
    var networkGateway

    var body: some ReducerOf<Self> {
      userInputReducer
        .ifLet(\.$episodeDetails, action: \.episodeDetails) {
          EpisodeDetailsFeature.FeatureReducer()
        }
      paginationReducer
    }

    var userInputReducer: some ReducerOf<Self> {
      Reduce { (state: inout State, action: Action) in
        switch action {
        case .presetEpisode(let episode):
          state.episodeDetails = .init(episode: episode)
          return .none
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
    var episodeDetails: EpisodeDetailsFeature.FeatureState?

    static func initial(firstPageURL: URL?) -> Self {
      FeatureState(pagination: .initial(firstInput: firstPageURL))
    }
  }

  @CasePathable
  enum FeatureAction: Equatable {
    case presetEpisode(EpisodeDomainModel)
    case pagination(PaginationFeature.FeatureAction)
    case episodeDetails(PresentationAction<EpisodeDetailsFeature.FeatureAction>)
  }
}

#Preview {
  @Previewable @State var store = EpisodeListFeature.previewStore(
    dependencies: Dependencies.preview()
  )

  VStack {
    NavigationStack {
      EpisodeListFeature.FeatureView(store: store)
        .navigationTitle("Test Episode List")
    }
  }
}

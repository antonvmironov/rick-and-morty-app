import ComposableArchitecture
import Foundation
import SharedLib
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
    @Bindable
    var store: FeatureStore

    init(store: FeatureStore) {
      self.store = store
    }

    var body: some View {
      episodeList()
        .navigationTitle("Episode List")
    }

    func episodeRow(
      episode: EpisodeDomainModel,
      isPlaceholder: Bool
    ) -> some View {
      HStack(spacing: UIConstants.space) {
        ListItemFeature.FeatureView(
          state: .init(episode: episode, isPlaceholder: isPlaceholder)
        )
        Image(systemName: "chevron.right")
      }
    }

    func episodeListItems() -> some View {
      ForEach(store.pagination.items) { episode in
        Button(
          action: {
            store.send(.presetEpisode(episode))
          },
          label: {
            episodeRow(episode: episode, isPlaceholder: false)
          }
        )
        .listRowSeparator(.hidden)
        .tag(episode.id)
      }
    }

    func skeletonListItems() -> some View {
      ForEach(
        Array(repeatElement(EpisodeDomainModel.dummy, count: 20).enumerated()),
        id: \.offset
      ) { element in
        episodeRow(episode: element.element, isPlaceholder: true)
          .listRowSeparator(.hidden)
          .tag(element.offset)
      }
    }

    func lastItem() -> some View {
      Group {
        if store.pagination.nextInput != nil {
          HStack {
            if store.pagination.pageLoading.status.isProcessing {
              ProgressView()
              Text("Loading the next page...")
            } else {
              Text("Next page placeholder")
            }
          }
          .onAppear {
            store.send(.pagination(.loadNextPage))
          }
          .frame(maxWidth: .infinity, alignment: .center)
          .listRowSeparator(.hidden)
          .tag("last-item")
        } else {
          HStack {
            Text("No new episodes")
          }
          .frame(maxWidth: .infinity, alignment: .center)
          .listRowSeparator(.hidden)
          .tag("last-item")
        }
      }
    }

    func episodeList() -> some View {
      List {
        if let previousFailure = store.pagination.pageLoading.status
          .failureMessage
        {
          Text("Failure \(previousFailure)")
        }
        if store.pagination.items.isEmpty {
          skeletonListItems()
        } else {
          episodeListItems()
        }
        lastItem()
      }
      .listStyle(.plain)
      .onAppear {
        store.send(.pagination(.loadFirstPageIfNeeded))
      }
      .navigationDestination(
        item: $store.scope(
          state: \.selectedEpisodeDetails?.value,
          action: \.selectedEpisodeDetails
        )
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
      BindingReducer()
      episodeDetailsReducer
      userInputReducer
      paginationReducer
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

    static func initial(firstPageURL: URL?) -> Self {
      FeatureState(pagination: .initial(firstInput: firstPageURL))
    }
  }

  @CasePathable
  enum FeatureAction: Equatable, BindableAction {
    case presetEpisode(EpisodeDomainModel)
    case pagination(PaginationFeature.FeatureAction)
    case selectedEpisodeDetails(
      PresentationAction<EpisodeDetailsFeature.FeatureAction>
    )
    case binding(BindingAction<FeatureState>)
  }
}

#Preview {
  @Previewable @State var isPlaceholder = false
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

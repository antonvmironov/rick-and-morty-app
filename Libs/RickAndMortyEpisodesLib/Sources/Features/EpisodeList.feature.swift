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
        .refreshable {
          do {
            _ = try await withCheckedThrowingContinuation { continuation in
              store.send(.reload(continuation: continuation))
            }
          } catch {
            // TODO: handle this error
            print(error)
          }
        }
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

    static let cachedSinceFormatter: ISO8601DateFormatter = {
      let formatter = ISO8601DateFormatter()
      return formatter
    }()

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
            store.send(.pagination(.loadNextPage()))
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

    private func failureView(failureMessage: String) -> some View {
      Text("⚠️ \(failureMessage)")
        .font(.caption)
    }

    private func episodeList() -> some View {
      List {
        Section(
          content: {
            if store.pagination.items.isEmpty {
              skeletonListItems()
            } else {
              episodeListItems()
            }
            lastItem()
          },
          header: {
            if let failureMessage = store.failureMessage {
              failureView(failureMessage: failureMessage)
            } else if let date = store.cachedSince,
              let dateString = Self.cachedSinceFormatter.string(for: date)
            {
              HStack {
                Spacer()
                Text(
                  "cached on \(dateString)"
                )
                .font(.caption2)
              }
            }
          }
        )
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
    case pagination(PaginationFeature.FeatureAction)
    case reload(continuation: PaginationFeature.PageLoadingContinuation?)
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

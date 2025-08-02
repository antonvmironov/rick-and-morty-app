import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
enum EpisodeListFeature {
  // constants and shared functions go here

  static func formatAirDate(episode: EpisodeDomainModel) -> String {
    // implementing requirement "air date (in dd/mm/yyyy format)"
    let inputDateFormatter = DateFormatter()
    inputDateFormatter.dateFormat = "MMMM dd, yyyy"
    let outputDateFormatter = DateFormatter()
    outputDateFormatter.dateFormat = "dd/MM/yyyy"

    let inputValue = episode.airDate
    guard let inputDate = inputDateFormatter.date(from: inputValue)
    else { return inputValue }
    let outputString = outputDateFormatter.string(from: inputDate)
    return outputString
  }
}

struct EpisodeListView: View {
  @Bindable var store: EpisodeListStore

  init(store: EpisodeListStore) {
    self.store = store
  }

  var body: some View {
    episodeList()
      .navigationTitle("Episode List")
  }

  func episodeList() -> some View {
    List {
      ForEach(store.items) { episode in
        episodeRow(episode: episode)
          .listRowSeparator(.hidden)
          .tag(episode.id)
      }
      if store.nextPageURL != nil {
        HStack {
          if store.pageLoading.status.isProcessing {
            ProgressView()
          }
          Text("Loading the next page...")
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowSeparator(.hidden)
        .onAppear {
          store.send(.loadNextPage)
        }
      } else {
        HStack {
          Text("No new episodes")
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowSeparator(.hidden)
      }
    }
    .listStyle(.plain)
    .onAppear {
      store.send(.loadFirstPageIfNeeded)
    }
  }

  func episodeRow(episode: EpisodeDomainModel) -> some View {
    VStack {
      HStack {
        Text("\(episode.name)")
          .font(.title3)
        Spacer()
      }
      HStack {
        Text("\(episode.episode)")
          .font(.caption)
          .fontDesign(.monospaced)
        Text("\(EpisodeListFeature.formatAirDate(episode: episode))")
          .font(.caption)
          .fontDesign(.monospaced)
        Spacer()
      }
    }
  }
}

#Preview {
  NavigationStack {
    EpisodeListView(store: EpisodeListStore.preview())
      .navigationTitle("Test Episode List")
  }
}

typealias EpisodeListStore = StoreOf<EpisodeListReducer>
typealias EpisodeListTestStore = TestStoreOf<EpisodeListReducer>

extension EpisodeListStore {
  static func preview() -> EpisodeListStore {
    return initial(
      firstEpisodePageURL: MockNetworkGateway.exampleAPIURL
    ) { deps in
      deps.networkGateway = try! MockNetworkGateway.preview()
    }
  }

  static func initial(
    firstEpisodePageURL: URL,  // TODO: pass an URL to the first episode page
    withDependencies setupDependencies: @escaping (inout DependencyValues) ->
      Void
  ) -> EpisodeListStore {
    let state = EpisodeListState()
    return EpisodeListStore(
      initialState: state,
      reducer: {
        EpisodeListReducer()
      },
      withDependencies: setupDependencies
    )
  }
}

@Reducer
struct EpisodeListReducer {
  typealias State = EpisodeListState
  typealias Action = EpisodeListAction

  @Dependency(\.networkGateway)
  var networkGateway

  var body: some ReducerOf<Self> {
    paginatonReducer
    pageLoadingReducer
  }

  private static let fetchEpisodesCancelID = "fetch-episodes"

  private var paginatonReducer: some ReducerOf<Self> {
    Reduce { state, action in
      switch (state.pageLoading.status, action) {
      case (_, .setFirstPageURL(let pageURL)):
        state.firstPageURL = pageURL
        state.reset()
        return .send(.loadNextPage)
      case (.idle, .loadFirstPageIfNeeded):
        guard state.needsToLoadFirstPage else {
          return .none
        }
        return .send(.loadNextPage)
      case (.idle, .loadNextPage):
        guard let nextPageURL = state.nextPageURL else {
          return .none
        }
        return .send(.pageLoading(.process(nextPageURL)))
      case (.processing, .pageLoading(.finishProcessing(let page))):
        state.appendPage(page)
        return .none
      default:
        return .none
      }
    }
  }

  private var pageLoadingReducer: some ReducerOf<Self> {
    Scope(state: \.pageLoading, action: \.pageLoading) {
      ProcessHostReducer<URL, ResponsePageContainer<EpisodeDomainModel>> {
        [networkGateway] pageURL in
        try await networkGateway.getPageOfEpisodes(
          pageURL: pageURL,
          cachePolicy: .returnCacheDataElseLoad
        )
      }
    }
  }
}

@ObservableState
struct EpisodeListState: Equatable {
  static func initial() -> Self {
    .init()
  }

  typealias Page = ResponsePageContainer<EpisodeDomainModel>
  var firstPageURL: URL?
  var pages = [Page]()
  var items = IdentifiedArray<EpisodeID, EpisodeDomainModel>()
  var nextPageURL: URL?
  var pageLoading:
    ProcessHostState<URL, ResponsePageContainer<EpisodeDomainModel>> =
      .initial()
  var needsToLoadFirstPage: Bool {
    pages.isEmpty && canLoadNextPage
  }
  var canLoadNextPage: Bool {
    nextPageURL != nil
  }

  mutating func appendPage(
    _ page: ResponsePageContainer<EpisodeDomainModel>
  ) {
    let nextExpectedPage = nextPageURL

    if page.payload.info.prev == nil || nextExpectedPage != page.pageURL {
      // got a new first page. Must reset
      reset()
    }

    pages.append(page)
    items.append(contentsOf: page.payload.results)
    nextPageURL = page.payload.info.next
  }

  mutating func reset() {
    items.removeAll()
    pages.removeAll()
    nextPageURL = firstPageURL
  }
}

@CasePathable
enum EpisodeListAction: Equatable {
  case setFirstPageURL(pageURL: URL)
  case loadNextPage
  case loadFirstPageIfNeeded

  case pageLoading(
    ProcessHostAction<URL, ResponsePageContainer<EpisodeDomainModel>>
  )
}

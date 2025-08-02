import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
enum EpisodeListFeature {
  typealias PageLoadingReducer = ProcessHostReducer<URL, ResponsePageContainer<EpisodeDomainModel>>
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
  @State
  var store: EpisodeListStore

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
            Text("Loading the next page...")
          } else {
            Text("Next page placeholder")
          }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowSeparator(.hidden)
        .tag("next-page")
        .onAppear {
          store.send(.loadNextPage)
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
  @Previewable @State var store = EpisodeListStore.preview(
    dependencies: Dependencies.preview()
  )

  VStack {
    NavigationStack {
      EpisodeListView(store: store)
        .navigationTitle("Test Episode List")
    }
  }
}

typealias EpisodeListStore = StoreOf<EpisodeListReducer>
typealias EpisodeListTestStore = TestStoreOf<EpisodeListReducer>

extension EpisodeListStore {
  static func preview(
    dependencies: Dependencies
  ) -> EpisodeListStore {
    initial(
      firstPageURL: MockNetworkGateway.exampleAPIURL
    ) { deps in
      dependencies.updateDeps(&deps)
    }
  }

  static func initial(
    firstPageURL: URL,
    withDependencies setupDependencies: @escaping (inout DependencyValues) ->
      Void
  ) -> EpisodeListStore {
    let state = EpisodeListState.initial(firstPageURL: firstPageURL)
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
  static func initial(firstPageURL: URL? = nil) -> Self {
    .init(
      firstPageURL: firstPageURL,
      nextPageURL: firstPageURL,
    )
  }

  typealias Page = ResponsePageContainer<EpisodeDomainModel>
  var firstPageURL: URL?
  var pages = [Page]()
  var items = [EpisodeDomainModel]()
  var nextPageURL: URL?
  var pageLoading: EpisodeListFeature.PageLoadingReducer.State = .initial()
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

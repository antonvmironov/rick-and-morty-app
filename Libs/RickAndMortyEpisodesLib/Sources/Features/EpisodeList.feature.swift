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
      if let nextPageURL = store.nextPageURL {
        HStack {
          if store.loadingStatus == .loadingPage {
            ProgressView()
          }
          Text("Loading the next page...")
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowSeparator(.hidden)
        .onAppear {
          store.send(.loadNextEpisodesPage(pageURL: nextPageURL))
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
      store.send(.didAppear)
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
    loadingReducer
  }

  private static let fetchEpisodesCancelID = "fetch-episodes"

  private var loadingReducer: some ReducerOf<Self> {
    Reduce { state, action in
      switch (state.loadingStatus, action) {
      case (_, .setFirstPageLoadingURL(let pageURL)):
        guard state.firstEpisodePageURL != pageURL else { return .none }
        state.firstEpisodePageURL = pageURL
        state.reset()
        return .send(.loadFirstPage)
      case (.idle, .didAppear):
        return .send(.loadFirstPage)
      case (.idle, .loadFirstPage):
        guard let firstEpisodePageURL = state.firstEpisodePageURL else {
          return .none
        }
        state.loadingStatus = .loadingPage
        return .run { send in
          await loadPageEffect(pageURL: firstEpisodePageURL, send: send)
        }.cancellable(id: Self.fetchEpisodesCancelID)
      case (.idle, .loadNextEpisodesPage(let pageURL)):
        state.loadingStatus = .loadingPage
        return .run { send in
          await loadPageEffect(pageURL: pageURL, send: send)
        }.cancellable(id: Self.fetchEpisodesCancelID)
      case (.loadingPage, .finishLoadingEpisodes(let page)):
        state.loadingStatus = .idle
        state.didLoad(page)
        return .none
      case (.loadingPage, .failLoadingEpisodes(let message)):
        state.loadingStatus = .failedToLoad(message: message)
        return .none
      default:
        return .none
      }
    }
  }

  func loadPageEffect(
    pageURL: URL,
    send: Send<Action>,
  ) async {
    do {
      let pageOfEpisodes = try await networkGateway.getPageOfEpisodes(
        pageURL: pageURL,
        cachePolicy: .returnCacheDataElseLoad
      )
      await send(.finishLoadingEpisodes(pageOfEpisodes))
    } catch {
      await send(.failLoadingEpisodes(message: "\(error)"))
    }
  }
}

@ObservableState
struct EpisodeListState: Equatable {
  static func initial() -> Self {
    .init()
  }

  typealias Page = ResponsePageContainer<EpisodeDomainModel>
  var firstEpisodePageURL: URL?
  var pages = [Page]()
  var items = IdentifiedArray<EpisodeID, EpisodeDomainModel>()
  var nextPageURL: URL?
  var loadingStatus: EpisodeListLoadingStatus = .idle

  mutating func didLoad(
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
    loadingStatus = .idle
  }

  mutating func reset() {
    items.removeAll()
    pages.removeAll()
    nextPageURL = nil
  }
}

@CasePathable
enum EpisodeListAction: Equatable {
  case setFirstPageLoadingURL(pageURL: URL)
  case didAppear
  case loadFirstPage
  case loadNextEpisodesPage(pageURL: URL)
  case finishLoadingEpisodes(ResponsePageContainer<EpisodeDomainModel>)
  case failLoadingEpisodes(message: String)
}

enum EpisodeListLoadingStatus: Equatable {
  case idle
  case loadingPage
  case failedToLoad(message: String)
}

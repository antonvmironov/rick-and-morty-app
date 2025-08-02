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
      ForEach(store.latestController.items) { episode in
        episodeRow(episode: episode)
          .listRowSeparator(.hidden)
          .tag(episode.id)
      }
      if let nextPageURL = store.latestController.nextPageURL {
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
      apiURL: MockNetworkGateway.exampleAPIURL
    ) { deps in
      deps.networkGateway = try! MockNetworkGateway.preview()
    }
  }

  static func initial(
    apiURL: URL,  // TODO: pass an URL to the first episode page
    withDependencies setupDependencies: @escaping (inout DependencyValues) ->
      Void
  ) -> EpisodeListStore {
    let state = EpisodeListState()
    return EpisodeListStore(
      initialState: state,
      reducer: {
        EpisodeListReducer(apiURL: apiURL)
      },
      withDependencies: setupDependencies
    )
  }
}

@Reducer
struct EpisodeListReducer {
  typealias State = EpisodeListState
  typealias Action = EpisodeListAction

  let apiURL: URL

  @Dependency(\.networkGateway)
  var networkGateway

  var body: some ReducerOf<Self> {
    loadingReducer
  }

  private var loadingReducer: some ReducerOf<Self> {
    Reduce { state, action in
      switch (state.loadingStatus, action) {
      case (.idle, .didAppear):
        return .send(.loadingFirstPage)
      case (.idle, .loadingFirstPage):
        state.loadingStatus = .loadingPage
        return .run { send in
          await loadPageEffect(pageURL: nil, send: send)
        }.cancellable(id: "fetch-episodes")
      case (.idle, .loadNextEpisodesPage(let pageURL)):
        state.loadingStatus = .loadingPage
        return .run { send in
          await loadPageEffect(pageURL: pageURL, send: send)
        }.cancellable(id: "fetch-episodes")
      case (.loadingPage, .finishLoadingEpisodes(let page)):
        state.loadingStatus = .idle
        state.latestController.didLoad(page)
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
    pageURL: URL?,
    send: Send<Action>,
  ) async {
    do {
      let effectivePageURL: URL
      if let pageURL {
        effectivePageURL = pageURL
      } else {
        let endpoints = try await networkGateway.getEndpoints(
          apiURL: apiURL
        ).output
        effectivePageURL = endpoints.episodes
      }
      let pageOfEpisodes = try await networkGateway.getPageOfEpisodes(
        pageURL: effectivePageURL,
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
  var latestController = EpisodeListController()
  var loadingStatus: EpisodeListLoadingStatus = .idle
}

@CasePathable
enum EpisodeListAction: Equatable {
  case didAppear
  case loadingFirstPage
  case loadNextEpisodesPage(pageURL: URL)
  case finishLoadingEpisodes(ResponsePageContainer<EpisodeDomainModel>)
  case failLoadingEpisodes(message: String)
}

enum EpisodeListLoadingStatus: Equatable {
  case idle
  case loadingPage
  case failedToLoad(message: String)
}

struct EpisodeListController: Sendable, Equatable {
  typealias Page = ResponsePageContainer<EpisodeDomainModel>
  var pages = [Page]()
  var items = IdentifiedArray<EpisodeID, EpisodeDomainModel>()
  var nextPageURL: URL?

  init() {}

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
  }

  mutating func reset() {
    items.removeAll()
    pages.removeAll()
    nextPageURL = nil
  }
}

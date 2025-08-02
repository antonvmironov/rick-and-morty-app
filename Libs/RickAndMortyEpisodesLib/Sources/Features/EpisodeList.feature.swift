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
    VStack {
      switch store.state.loadingStatus {
      case .idle:
        if store.latestController.items.isEmpty {
          Text("TBD: display skeleton on this page while idle")
        } else {
          episodeList()
        }
      case .loadingEpisodeList:
        Text("TBD: display skeleton on this page while Loading")
      case .failedToLoad(let message):
        Text("Failed \(message)")
      }
    }.onAppear {
      store.send(.episodeListDidAppear)
    }
  }

  func episodeList() -> some View {
    List {
      ForEach(store.latestController.items) { episode in
        episodeRow(episode: episode)
          .listRowSeparator(.hidden)
          .tag(episode.id)
      }
    }
    .listStyle(.plain)
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
    .padding(4)
  }
}

#Preview {
  EpisodeListView(store: EpisodeListStore.preview())
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
    apiURL: URL,
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
      case (.idle, .episodeListDidAppear):
        return .send(.startLoadingEpisodes)
      case (.idle, .startLoadingEpisodes):
        state.loadingStatus = .loadingEpisodeList
        return .run { send in
          await loadPageOfEpisodesEffect(send: send)
        }.cancellable(id: "fetch-episodes")
      case (.loadingEpisodeList, .finishLoadingEpisodes(let page)):
        state.loadingStatus = .idle
        state.latestController.didLoad(page)
        return .none
      case (.loadingEpisodeList, .failLoadingEpisodes(let message)):
        state.loadingStatus = .failedToLoad(message: message)
        return .none
      default:
        return .none
      }
    }
  }

  func loadPageOfEpisodesEffect(send: Send<Action>) async {
    do {
      let endpoints = try await networkGateway.getEndpoints(
        apiURL: apiURL
      ).output
      let pageOfEpisodes = try await networkGateway.getPageOfEpisodes(
        pageURL: endpoints.episodes,
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
  case episodeListDidAppear
  case startLoadingEpisodes
  case finishLoadingEpisodes(ResponsePageContainer<EpisodeDomainModel>)
  case failLoadingEpisodes(message: String)
}

enum EpisodeListLoadingStatus: Equatable {
  case idle
  case loadingEpisodeList
  case failedToLoad(message: String)
}

struct EpisodeListController: Sendable, Equatable {
  typealias Page = ResponsePageContainer<EpisodeDomainModel>
  var pages = [Page]()
  var items = IdentifiedArray<EpisodeID, EpisodeDomainModel>()

  init() {}

  mutating func didLoad(
    _ page: ResponsePageContainer<EpisodeDomainModel>
  ) {
    let nextExpectedPage = pages.last?.payload.info.next

    if page.payload.info.prev == nil || nextExpectedPage != page.pageURL {
      // got a new first page. Must rebuild all items
      items.removeAll()
      pages.removeAll()
    }

    pages.append(page)
    items.append(contentsOf: page.payload.results)
  }
}

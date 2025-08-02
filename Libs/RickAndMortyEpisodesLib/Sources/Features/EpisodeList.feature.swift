import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
enum EpisodeListFeature {
  // constants and shared functions go here

  static func airDateFormatter(episode: EpisodeDomainModel) -> String {
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
      switch store.state.route {
      case .idle:
        Text("Idle")
      case .loadingEpisodeList:
        Text("Loading...")
      case .loadedEpisodeList(let page, let cachedSince):
        List {
          ForEach(page.results) { episode in
            episodeRow(episode: episode)
              .listRowSeparator(.hidden)
              .tag(episode.id)
          }
        }
        .listStyle(.plain)
      case .loadingEpisodeListFailed(let message):
        Text("Failed \(message)")
      }
    }.onAppear {
      store.send(.episodeListDidAppear)
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
        Text("\(EpisodeListFeature.airDateFormatter(episode: episode))")
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
      switch (state.route, action) {
      case (.idle, .episodeListDidAppear):
        return .send(.startLoadingEpisodes)
      case (.idle, .startLoadingEpisodes):
        state.route = .loadingEpisodeList
        let networkGateway = self.networkGateway
        let apiURL = self.apiURL
        return .run { send in
          do {
            let endpoints = try await networkGateway.getEndpoints(
              apiURL: apiURL
            ).output
            let pageOfEpisodes = try await networkGateway.getPageOfEpisodes(
              pageURL: endpoints.episodes,
              cachePolicy: .returnCacheDataElseLoad
            )
            await send(
              .finishLoadingEpisodes(
                page: pageOfEpisodes.output,
                cachedSince: pageOfEpisodes.cachedSince,
              )
            )
          } catch {
            await send(.failLoadingEpisodes(message: "\(error)"))
          }
        }.cancellable(id: "fetch-episodes")
      case (
        .loadingEpisodeList, .finishLoadingEpisodes(let page, let cachedSince)
      ):
        state.route = .loadedEpisodeList(page: page, cachedSince: cachedSince)
        return .none
      case (.loadingEpisodeList, .failLoadingEpisodes(let message)):
        state.route = .loadingEpisodeListFailed(message: message)
        return .none
      default:
        return .none
      }
    }
  }
}

@ObservableState
struct EpisodeListState: Equatable {
  var route = EpisodeListRoute.idle
}

@CasePathable
enum EpisodeListAction: Equatable {
  case increment
  case episodeListDidAppear
  case startLoadingEpisodes
  case finishLoadingEpisodes(
    page: ResponsePage<EpisodeDomainModel>,
    cachedSince: Date?
  )
  case failLoadingEpisodes(
    message: String
  )
}

enum EpisodeListRoute: Equatable {
  case idle
  case loadingEpisodeList
  case loadedEpisodeList(
    page: ResponsePage<EpisodeDomainModel>,
    cachedSince: Date?
  )
  case loadingEpisodeListFailed(
    message: String
  )
}

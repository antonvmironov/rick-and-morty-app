import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the EpisodeList feature. Serves as an anchor for project navigation.
enum EpisodeListFeature {
  typealias PaginationFeature = ContinuousPaginationFeature<
    URL, EpisodeDomainModel
  >
  typealias FeatureStore = StoreOf<FeatureReducer>

  @MainActor
  static func previewStore(
    dependencies: Dependencies
  ) -> FeatureStore {
    let initialState = FeatureState(
      pagination: .initial(firstInput: MockNetworkGateway.exampleAPIURL)
    )
    return FeatureStore(
      initialState: initialState,
      reducer: { FeatureReducer() },
      withDependencies: dependencies.updateDeps
    )
  }

  static func formatAirDate(episode: EpisodeDomainModel) -> String {
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
        ForEach(store.pagination.items) { episode in
          episodeRow(episode: episode)
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

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    @Dependency(\.networkGateway)
    var networkGateway

    var body: some ReducerOf<Self> {
      paginationReducer
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

    static func initial(firstPageURL: URL?) -> Self {
      FeatureState(pagination: .initial(firstInput: firstPageURL))
    }
  }

  @CasePathable
  enum FeatureAction {
    case pagination(PaginationFeature.FeatureAction)
  }
}

#Preview {
  @Previewable @State var store = EpisodeListFeature.previewStore(
    dependencies: try! Dependencies.preview()
  )

  VStack {
    NavigationStack {
      EpisodeListFeature.FeatureView(store: store)
        .navigationTitle("Test Episode List")
    }
  }
}

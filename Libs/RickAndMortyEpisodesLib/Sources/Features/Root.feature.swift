import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the RootFeature feature. Serves as an anchor for project navigation.
public enum RootFeature {
  typealias FeatureStore = StoreOf<FeatureReducer>
  typealias EndpointsLoadingFeature = ProcessHostFeature<
    URL, EndpointsDomainModel
  >
  enum A11yIDs: String, A11yIDProvider {
    case enterSettingsButton = "enter-settings-button"
    case exitSettingsButton = "escape-settings-button"
    var a11yID: String { rawValue }
  }

  @MainActor
  public static func rootView(
    apiURL: URL,
    dependencies: Dependencies
  ) -> some View {
    let store = initialStore(apiURL: apiURL, dependencies: dependencies)
    return FeatureView(store: store, apiURL: apiURL)
  }

  @MainActor
  static func initialStore(
    apiURL: URL,
    dependencies: Dependencies
  ) -> FeatureStore {
    let cachedEndpoints = try? dependencies.networkGateway
      .getCachedEndpoints(apiURL: apiURL)?.output
    let endpointsLoading = EndpointsLoadingFeature.FeatureState
      .initial(cachedSuccess: cachedEndpoints)
    let episodeList: EpisodesRootFeature.FeatureState = {
      guard let firstPageURL = cachedEndpoints?.episodes else {
        return EpisodesRootFeature.FeatureState
          .initial(firstPageURL: cachedEndpoints?.episodes)
      }
      let cachedFirstPage = try? dependencies.networkGateway
        .getPageOfCachedEpisodes(pageURL: firstPageURL)
      guard let cachedFirstPage else {
        return EpisodesRootFeature.FeatureState
          .initial(firstPageURL: cachedEndpoints?.episodes)
      }

      return EpisodesRootFeature.FeatureState
        .initialFromCache(firstPageURL: firstPageURL, pages: [cachedFirstPage])
    }()

    let initialState = FeatureState(
      endpointsLoading: endpointsLoading,
      episodeList: episodeList,
      settings: .init()
    )
    return FeatureStore(
      initialState: initialState,
      reducer: {
        FeatureReducer(apiURL: apiURL)
      },
      withDependencies: dependencies.updateDeps
    )
  }

  public struct FeatureView: View {
    @Bindable
    var store: FeatureStore

    let apiURL: URL

    init(store: FeatureStore, apiURL: URL) {
      self.store = store
      self.apiURL = apiURL
    }

    public var body: some View {
      NavigationStack {
        EpisodesRootFeature.FeatureView(
          store: store.scope(state: \.episodeList, action: \.episodeList)
        )
        .onAppear {
          store.send(.preloadIfNeeded)
        }
        .toolbar {
          ToolbarItem {
            toggleSettingsPresentedButton(
              title: "Settings",
              iconSystemName: "figure.walk"
            )
            .a11yID(A11yIDs.enterSettingsButton)
            .padding(UIConstants.space)
          }
        }
      }
      .sheet(isPresented: $store.isSettingsPresented) {
        NavigationStack {
          SettingsFeature.FeatureView(
            store: store.scope(
              state: \.settings,
              action: \.settings
            )
          )
        }
        .overlay(alignment: .topTrailing) {
          toggleSettingsPresentedButton(
            title: "Back",
            iconSystemName: "escape"
          )
          .a11yID(A11yIDs.exitSettingsButton)
          .padding(UIConstants.space)
        }
      }
    }

    private func toggleSettingsPresentedButton(
      title: String,
      iconSystemName: String
    ) -> some View {
      Button(
        action: {
          store.send(.toggleSettingsPresentation)
        },
        label: {
          Label(
            title: {
              Text("Settings")
            },
            icon: {
              Image(systemName: iconSystemName)
            }
          ).labelStyle(.iconOnly)
        }
      )
      .aspectRatio(1, contentMode: .fit)
      .buttonStyle(.bordered)
      .accessibilityHidden(true)
    }
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    let apiURL: URL

    @Dependency(\.networkGateway)
    var networkGateway: NetworkGateway

    var body: some ReducerOf<Self> {
      coordinatingReducer
      Scope(state: \.endpointsLoading, action: \.endpointsLoading) {
        [networkGateway] in
        EndpointsLoadingFeature.FeatureReducer { apiURL in
          let response = try await networkGateway.getEndpoints(
            apiURL: apiURL
          )
          return response.output
        }
      }
      Scope(state: \.episodeList, action: \.episodeList) {
        EpisodesRootFeature.FeatureReducer()
      }
      Scope(state: \.settings, action: \.settings) {
        SettingsFeature.FeatureReducer()
      }
      BindingReducer()
    }

    var coordinatingReducer: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .preloadIfNeeded:
          if let endpoints = state.endpointsLoading.status.success {
            let action: Action = .episodeList(
              .pagination(.setFirstInput(input: endpoints.episodes))
            )
            return .send(action)
          } else {
            return .send(.endpointsLoading(.process(apiURL)))
          }
        case .toggleSettingsPresentation:
          state.isSettingsPresented.toggle()
          return .none
        case .endpointsLoading(.finishProcessing(let endpoints)):
          let action: Action = .episodeList(
            .pagination(.setFirstInput(input: endpoints.episodes))
          )
          return .send(action)
        default:
          return .none
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var endpointsLoading: EndpointsLoadingFeature.FeatureState
    var episodeList: EpisodesRootFeature.FeatureState
    var settings: SettingsFeature.FeatureState
    var isSettingsPresented = false
  }

  @CasePathable
  enum FeatureAction: BindableAction {
    case preloadIfNeeded
    case toggleSettingsPresentation
    case endpointsLoading(EndpointsLoadingFeature.FeatureAction)
    case episodeList(EpisodesRootFeature.FeatureAction)
    case settings(SettingsFeature.FeatureAction)
    case binding(BindingAction<FeatureState>)
  }
}

#Preview {
  @Previewable let dependencies = Dependencies.preview()
  RootFeature
    .rootView(
      apiURL: MockNetworkGateway.exampleAPIURL,
      dependencies: dependencies
    )
    .navigationTitle("Test Episode List")
}

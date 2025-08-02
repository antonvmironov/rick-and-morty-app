import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the ContinuousPagination feature. Serves as an anchor for project navigation.
enum ContinuousPaginationFeature<
  Input: Equatable & Sendable,
  Item: Equatable & Sendable & Codable & Identifiable
> {
  typealias Page = ResponsePageContainer<Item>
  typealias PageLoadingFeature = ProcessHostFeature<Input, Page>
  typealias FeatureStore = StoreOf<FeatureReducer>
  typealias TestStore = TestStoreOf<FeatureReducer>
  typealias GetPage = @Sendable (Input) async throws -> Page
  typealias GetNextInput = @Sendable (Page) -> Input?
  typealias IsPageFirst = @Sendable (Page) -> Bool

  @MainActor
  static func previewStore(
    initialInput: Input,
    getPage: @escaping GetPage,
    getNextInput: @escaping GetNextInput,
    isPageFirst: @escaping IsPageFirst,
    dependencies: Dependencies
  ) -> FeatureStore {
    initialStore(
      firstInput: initialInput,
      getPage: getPage,
      getNextInput: getNextInput,
      isPageFirst: isPageFirst,
      withDependencies: dependencies.updateDeps,
    )
  }

  @MainActor
  static func initialStore(
    firstInput: Input,
    getPage: @escaping GetPage,
    getNextInput: @escaping GetNextInput,
    isPageFirst: @escaping IsPageFirst,
    withDependencies setupDependencies: @escaping (inout DependencyValues) ->
      Void
  ) -> FeatureStore {
    return FeatureStore(
      initialState: .initial(firstInput: firstInput),
      reducer: {
        FeatureReducer(
          getPage: getPage,
          getNextInput: getNextInput,
          isPageFirst: isPageFirst
        )
      },
      withDependencies: setupDependencies
    )
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction
    let getPage: GetPage
    let getNextInput: GetNextInput
    let isPageFirst: IsPageFirst

    var body: some ReducerOf<Self> {
      paginationReducer
      pageLoadingReducer
    }

    private var paginationReducer: some ReducerOf<Self> {
      Reduce { state, action in
        switch (state.pageLoading.status, action) {
        case (_, .setFirstInput(let input)):
          state.firstInput = input
          state.reset()
          return .send(.loadNextPage)
        case (.idle, .loadFirstPageIfNeeded):
          guard state.needsToLoadFirstPage else {
            return .none
          }
          return .send(.loadNextPage)
        case (.idle, .loadNextPage):
          guard let nextInput = state.nextInput else {
            return .none
          }
          return .send(.pageLoading(.process(nextInput)))
        case (.processing, .pageLoading(.finishProcessing(let page))):
          if isPageFirst(page) {
            state.reset()
          }

          state.pages.append(page)
          state.items.append(contentsOf: page.payload.results)
          state.nextInput = getNextInput(page)
          return .none
        default:
          return .none
        }
      }
    }

    private var pageLoadingReducer: some ReducerOf<Self> {
      Scope(state: \.pageLoading, action: \.pageLoading) {
        PageLoadingFeature.FeatureReducer(operation: getPage)
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    static func initial(firstInput: Input? = nil) -> Self {
      .init(
        firstInput: firstInput,
        nextInput: firstInput
      )
    }

    var firstInput: Input?
    var items = IdentifiedArray<Item.ID, Item>()
    var pages = [Page]()
    var nextInput: Input?
    var pageLoading: PageLoadingFeature.FeatureState = .initial()
    var needsToLoadFirstPage: Bool {
      items.isEmpty && canLoadNextPage
    }
    var canLoadNextPage: Bool {
      nextInput != nil
    }

    mutating func reset() {
      items.removeAll()
      pages.removeAll()
      nextInput = firstInput
    }
  }

  @CasePathable
  enum FeatureAction {
    case setFirstInput(input: Input)
    case loadNextPage
    case loadFirstPageIfNeeded
    case pageLoading(PageLoadingFeature.FeatureAction)
  }
}

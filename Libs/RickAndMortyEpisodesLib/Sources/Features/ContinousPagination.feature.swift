import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

/// Namespace for the ContinuousPagination feature. Serves as an anchor for project navigation.
enum ContinuousPaginationFeature<
  Input: Equatable & Sendable,
  Item: Equatable & Sendable & Codable & Identifiable
>: Feature {
  typealias FeatureView = Never

  typealias Page = ResponsePageContainer<Item>
  typealias PageLoadingFeature = ProcessHostFeature<Input, Page>
  typealias PageLoadingContinuation = CheckedContinuation<Page, Error>
  typealias GetPage = @Sendable (Input) async throws -> Page
  typealias GetNextInput = @Sendable (Page) -> Input?
  typealias IsPageFirst = @Sendable (Page) -> Bool

  @MainActor
  static func previewStore(
    firstInput: Input,
    getPage: @escaping GetPage,
    getNextInput: @escaping GetNextInput,
    isPageFirst: @escaping IsPageFirst,
    dependencies: Dependencies
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
      withDependencies: dependencies.updateDeps,
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
          guard input != state.firstInput else {
            return .none
          }
          state.firstInput = input
          state.reset()
          return .send(.loadNextPage())
        case (.idle, .loadFirstPageIfNeeded):
          guard state.needsToLoadFirstPage else {
            return .none
          }
          return .send(.loadNextPage())
        case (.idle, .loadNextPage(let continuation)):
          if let continuation {
            state.finishedLoadingPageContinuations.append(continuation)
          }
          guard let nextInput = state.nextInput else {
            return .none
          }
          return .send(.pageLoading(.process(nextInput)))
        case (.idle, .reload(let continuation)):
          state.reset()
          return .send(.loadNextPage(continuation: continuation))
        case (.processing, .pageLoading(.failedProcessing)):
          let continuations = state.finishedLoadingPageContinuations
          state.finishedLoadingPageContinuations.removeAll()
          return .run { _ in
            // TODO: test this and make a dedicated error
            for continuation in continuations {
              continuation.resume(throwing: CancellationError())
            }
          }
        case (.processing, .pageLoading(.finishProcessing(let page))):
          if isPageFirst(page) {
            state.reset()
          }

          state.pages.append(page)
          state.items.append(contentsOf: page.payload.results)
          state.nextInput = getNextInput(page)
          let continuations = state.finishedLoadingPageContinuations
          state.finishedLoadingPageContinuations.removeAll()
          return .run { _ in
            for continuation in continuations {
              continuation.resume(returning: page)
            }
          }
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
    static func initial(
      firstInput: Input? = nil,
    ) -> Self {
      .init(
        firstInput: firstInput,
        nextInput: firstInput
      )
    }

    static func initialFromCache(
      firstInput: Input,
      pages: [Page],
      nextInput: Input?,
    ) -> Self {
      .init(
        firstInput: firstInput,
        items: IdentifiedArray(
          uniqueElements: pages.flatMap(\.payload.results)
        ),
        pages: pages,
        nextInput: nextInput
      )
    }

    var firstInput: Input?
    var items = IdentifiedArray<Item.ID, Item>()
    var pages = [Page]()
    var nextInput: Input?
    var pageLoading: PageLoadingFeature.FeatureState = .initial(
      cachedSuccess: nil
    )
    var finishedLoadingPageContinuations = [PageLoadingContinuation]()
    var cachedSince: Date? { pages.first?.cachedSince }

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

    static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.firstInput == rhs.firstInput
        && lhs.items == rhs.items
        && lhs.pages == rhs.pages
        && lhs.nextInput == rhs.nextInput
        && lhs.pageLoading == rhs.pageLoading
    }
  }

  @CasePathable
  enum FeatureAction {
    case setFirstInput(input: Input)
    case loadNextPage(continuation: PageLoadingContinuation? = nil)
    case loadFirstPageIfNeeded
    case reload(continuation: PageLoadingContinuation? = nil)
    case pageLoading(PageLoadingFeature.FeatureAction)
  }
}

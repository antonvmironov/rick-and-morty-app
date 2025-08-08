import ComposableArchitecture
import Foundation
import SharedLib
import SwiftUI

extension ContinuousPaginationFeature {
  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction
    let getPage: Deps.GetPage
    let getNextInput: Deps.GetNextInput
    let isPageFirst: Deps.IsPageFirst

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
        Deps.PageLoading.FeatureReducer(operation: getPage)
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
      pages: [Deps.Page],
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
    var pages = [Deps.Page]()
    var nextInput: Input?
    var pageLoading: Deps.PageLoading.FeatureState = .initial(
      cachedSuccess: nil
    )
    var finishedLoadingPageContinuations = [Deps.PageLoadingContinuation]()
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
    case loadNextPage(continuation: Deps.PageLoadingContinuation? = nil)
    case loadFirstPageIfNeeded
    case reload(continuation: Deps.PageLoadingContinuation? = nil)
    case pageLoading(Deps.PageLoading.FeatureAction)
  }
}

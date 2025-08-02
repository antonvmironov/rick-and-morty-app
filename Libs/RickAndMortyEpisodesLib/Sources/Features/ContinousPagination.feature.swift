import ComposableArchitecture
import Foundation
import SwiftUI

/// Namespace for the ContinousPagination feature. Serves as an anchor for project navigation.
enum ContinousPaginationFeature<
  Input: Equatable & Sendable,
  Item: Equatable & Sendable & Codable
> {
  typealias Output = ResponsePageContainer<Item>
  typealias PageLoadingFeature = ProcessHostFeature<Input, Output>
  typealias FeatureStore = StoreOf<FeatureReducer>
  typealias TestStore = TestStoreOf<FeatureReducer>
  typealias GetPage = @Sendable (Input) async throws -> Output

  @MainActor
  static func previewStore(
    initialInput: Input,
    getPage: @escaping @Sendable (
      Input
    ) async throws -> Output,
    dependencies: Dependencies
  ) -> FeatureStore {
    initialStore(
      firstInput: initialInput,
      getPage: getPage,
      withDependencies: dependencies.updateDeps
    )
  }

  @MainActor
  static func initialStore(
    firstInput: Input,
    getPage: @escaping @Sendable (
      Input
    ) async throws -> ContinousPaginationFeature<Input, Item>.Output,
    withDependencies setupDependencies: @escaping (inout DependencyValues) ->
      Void
  ) -> FeatureStore {
    return FeatureStore(
      initialState: .initial(firstInput: firstInput),
      reducer: {
        FeatureReducer(getPage: getPage)
      },
      withDependencies: setupDependencies
    )
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction
    let getPage: GetPage

    var body: some ReducerOf<Self> {
      paginatonReducer
      pageLoadingReducer
    }

    private var paginatonReducer: some ReducerOf<Self> {
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
        case (.processing, .pageLoading(.finishProcessing(let output))):
          state.appendPage(output)
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
    var items = [Item]()
    var nextInput: Input?
    var pageLoading: PageLoadingFeature.FeatureState = .initial()
    var needsToLoadFirstPage: Bool {
      items.isEmpty && canLoadNextPage
    }
    var canLoadNextPage: Bool {
      nextInput != nil
    }

    mutating func appendPage(_ output: Output) {
      // Custom logic to update items and nextInput based on output
      // This should be implemented by the consumer
    }

    mutating func reset() {
      items.removeAll()
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

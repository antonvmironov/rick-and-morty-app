import ComposableArchitecture
import Foundation
import SharedLib

extension SkeletonFeature {
  typealias FeatureStore = StoreOf<FeatureReducer>
  @Observable final class ProdViewModel: FeatureViewModel {
    private let store: FeatureStore

    init(store: FeatureStore) {
      self.store = store
    }

    var pi: Double { 3.14 }
    var number: Int { store.number }
    func increment(by value: Int) {
      store.send(.increment(byValue: value))
    }
    func decrement() {
      store.send(.decrement)
    }
  }

  @Reducer
  struct FeatureReducer {
    typealias State = FeatureState
    typealias Action = FeatureAction

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .increment(let byValue):
          state.number += byValue
          return .none
        case .decrement:
          state.number -= 1
          return .none
        }
      }
    }
  }

  @ObservableState
  struct FeatureState: Equatable {
    var number = 0
  }

  @CasePathable
  enum FeatureAction: Equatable {
    case increment(byValue: Int)
    case decrement
  }
}
